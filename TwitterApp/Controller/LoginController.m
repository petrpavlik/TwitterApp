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

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Hello";
    
    UIView* contentPlaceholderView = [UIView new];
    contentPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentPlaceholderView];
    
    UILabel* infoLabel = [UILabel new];
    infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    infoLabel.text = @"Tweetilus needs access to your Twitter account";
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
    
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoLabel]-20-[connectButton]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[infoLabel]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[connectButton]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[contentPlaceholderView]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(contentPlaceholderView)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentPlaceholderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-30]];
}

- (void)didSelectConnectButton {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0) {
                
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                //iOS 6 bug fix
                ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                twitterAccount.accountType = accountTypeTwitter;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [AFTwitterClient sharedClient].account = twitterAccount;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidGainAccessToAccountNotification object:nil];
                    [self dismissViewControllerAnimated:YES completion:NULL];
                });
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[[UIAlertView alloc] initWithTitle:@"Tweetilus failed to access your Twitter account" message:@"Please make sure you have an account set up in the settings and you haven't disabled access for Tweetilus." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            });
        }
    }];
}


@end
