//
//  TabBarController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "LoginController.h"
#import "TabBarController.h"
#import "AppDelegate.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    ACAccountStore* accountStore = appDelegate.accountStore;
    ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray* accounts = [accountStore accountsWithAccountType:twitterAccountType];
    
    BOOL showLoginScreen = NO;
    
    if (!accounts.count) {
        showLoginScreen = YES;
    }
    else {
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* username = [userDefaults objectForKey:kUserDefaultsKeyUsername];
        
        if (!username.length) {
            showLoginScreen = YES;
        }
        else {
            
            showLoginScreen = YES;
            
            for (ACAccount* account in accounts) {
                
                if ([account.username isEqualToString:username]) {

                    showLoginScreen = NO;
                    break;
                }
            }
        }
    }
    
    if (showLoginScreen) {
        
        LoginController* loginController = [LoginController new];
        [self presentViewController:loginController animated:YES completion:NULL];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
