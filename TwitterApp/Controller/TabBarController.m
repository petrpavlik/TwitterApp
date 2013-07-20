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
    
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray* accounts = [accountStore accountsWithAccountType:twitterAccountType];
    
    if (!accounts.count) {
        
        LoginController* loginController = [LoginController new];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
        navigationController.viewControllers = @[loginController];
        navigationController.restorationIdentifier = nil; //we don't want this to be restored
        
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
