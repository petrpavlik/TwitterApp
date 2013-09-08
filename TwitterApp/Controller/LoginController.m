//
//  LoginController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "AFTwitterClient.h"
#import "LoginController.h"
#import "AppDelegate.h"

@interface LoginController () <UIActionSheetDelegate>

@property(nonatomic, strong) ACAccountStore* accountStore;
@property(nonatomic, strong) NSArray* accounts;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView* contentPlaceholderView = [UIView new];
    contentPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentPlaceholderView];
    
    UILabel* helloLabel = [UILabel new];
    helloLabel.translatesAutoresizingMaskIntoConstraints = NO;
    helloLabel.text = @"Hello";
    helloLabel.textAlignment = NSTextAlignmentCenter;
    helloLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [contentPlaceholderView addSubview:helloLabel];
    
    UILabel* infoLabel = [UILabel new];
    infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    infoLabel.text = @"Tweetilus would like to access your Twitter account.";
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [contentPlaceholderView addSubview:infoLabel];
    
    UIButton* connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    connectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [connectButton setTitle:@"Connect with Twitter" forState:UIControlStateNormal];
    connectButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [connectButton addTarget:self action:@selector(didSelectConnectButton) forControlEvents:UIControlEventTouchUpInside];
    [contentPlaceholderView addSubview:connectButton];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    connectButton.tintColor = appDelegate.skin.linkColor;
    
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[helloLabel]-10-[infoLabel]-20-[connectButton(>=44)]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton, helloLabel)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[infoLabel]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[helloLabel]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(helloLabel)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[connectButton]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[contentPlaceholderView]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(contentPlaceholderView)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentPlaceholderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-30]];
    
    self.accountStore = appDelegate.accountStore;
}

- (void)didSelectConnectButton {
    
    ACAccountStore *accountStore = self.accountStore;
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0) {
                
                //iOS 6 bug fix
                //ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                //twitterAccount.accountType = accountTypeTwitter;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.accounts = accounts;
                
                    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Account" delegate:self cancelButtonTitle:Nil destructiveButtonTitle:Nil otherButtonTitles:nil];
                    
                    for (ACAccount* account in accounts) {
                        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                    }
                    
                    [actionSheet addButtonWithTitle:@"Cancel"];
                    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
                    
                    [actionSheet showInView:self.view];
                });
            }
            else {
                
                [[[UIAlertView alloc] initWithTitle:@"Tweetilus could not find any account" message:@"Please make sure you have an account set up in the settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error) {
                    [[LogService sharedInstance] logError:error];
                }
                
                [[[UIAlertView alloc] initWithTitle:@"Tweetilus failed to access your Twitter account" message:@"Please make sure you have an account set up in the settings and you haven't disabled access for Tweetilus." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            });
        }
    }];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    ACAccount* account = self.accounts[buttonIndex];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account.username forKey:kUserDefaultsKeyUsername];
    
    [AFTwitterClient sharedClient].account = account;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGainAccessToAccountNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
