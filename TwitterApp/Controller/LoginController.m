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
#import <Social/Social.h>

@interface LoginController () <UIActionSheetDelegate>

@property(nonatomic, strong) ACAccountStore* accountStore;
@property(nonatomic, strong) NSArray* accounts;

@property(nonatomic, strong) UIButton* connectButton;
@property(nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;

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
    self.connectButton = connectButton;
    
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView = activityIndicatorView;
    [contentPlaceholderView addSubview:activityIndicatorView];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    connectButton.tintColor = appDelegate.skin.linkColor;
    
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[helloLabel]-10-[infoLabel]-20-[connectButton(>=44)][activityIndicatorView]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton, helloLabel, activityIndicatorView)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[infoLabel]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[helloLabel]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(helloLabel)]];
    [contentPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[connectButton]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(infoLabel, connectButton)]];
    [contentPlaceholderView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentPlaceholderView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[contentPlaceholderView]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(contentPlaceholderView)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentPlaceholderView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-30]];
    
    self.accountStore = appDelegate.accountStore;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didSelectConnectButton {
    
    self.connectButton.enabled = NO;
    [self.activityIndicatorView startAnimating];
    
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.connectButton.enabled = YES;
                    [self.activityIndicatorView stopAnimating];
                    
                    [[[UIAlertView alloc] initWithTitle:@"Tweetilus could not find any Twitter account" message:@"Please make sure you have an account set up in the settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    
                    [[LogService sharedInstance] logEvent:@"no accounts found" userInfo:Nil];
                });
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.connectButton.enabled = YES;
                [self.activityIndicatorView stopAnimating];
                
                if (error) {
                    [[LogService sharedInstance] logError:error];
                }
                
                [[[UIAlertView alloc] initWithTitle:@"Tweetilus failed to access your Twitter account" message:@"Please make sure you have an account set up in the settings and you haven't disabled access for Tweetilus." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                
                [[LogService sharedInstance] logEvent:@"access to Twitter account probably disabled" userInfo:Nil];
            });
        }
    }];
}



#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {

        self.connectButton.enabled = YES;
        [self.activityIndicatorView stopAnimating];
        return;
    }
    
    ACAccount* account = self.accounts[buttonIndex];
    [self validateAccountAndDismissIfOk:account];
}

#pragma mark -

- (void)validateAccountAndDismissIfOk:(ACAccount*)account {
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/user_timeline.json"];
    NSDictionary *params = @{@"screen_name" : account.username,
                             @"include_rts" : @"0",
                             @"trim_user" : @"1",
                             @"count" : @"1"};
    SLRequest *request =
    [SLRequest requestForServiceType:SLServiceTypeTwitter
                       requestMethod:SLRequestMethodGET
                                 URL:url
                          parameters:params];
    
    //  Attach an account to the request
    [request setAccount:account];
    
    //  Step 3:  Execute the request
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.connectButton.enabled = YES;
            [self.activityIndicatorView stopAnimating];
           
            if (error) {
                
                [[LogService sharedInstance] logError:error];
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                
                return;
            }
            
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                
                [[LogService sharedInstance] logEvent:@"user logged in" userInfo:@{@"user": account.username}];
                
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:account.username forKey:kUserDefaultsKeyUsername];
                [userDefaults synchronize];
                
                [AFTwitterClient sharedClient].account = account;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidGainAccessToAccountNotification object:nil];
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            else {
                
                [[LogService sharedInstance] logEvent:@"account validation failed" userInfo:@{@"user": account.username}];
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please check that your Twitter account has a password set." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
        });
    }];
}

@end
