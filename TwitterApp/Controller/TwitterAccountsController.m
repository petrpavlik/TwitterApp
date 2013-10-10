//
//  TwitterAccountsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/24/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TwitterAccountsController.h"
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "LoginController.h"
#import "TabBarController.h"
#import "TimelineController.h"
#import "MentionsController.h"
#import "SearchController.h"
#import "MyProfileController.h"
#import "AFTwitterClient.h"

#import "WebControllerTransition.h"

@interface TwitterAccountsController ()

@property(nonatomic, strong) NSArray* accounts;
@property(nonatomic) BOOL viewDidApplearAtLeastOnce;

@end

@implementation TwitterAccountsController

- (void)dealloc {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //self.navigationController.navigationBar.translucent = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (!weakSelf || !weakSelf.viewDidApplearAtLeastOnce) {
            
            NSLog(@"god damn black screen situation");
#ifdef DEBUG
            [[[UIAlertView alloc] initWithTitle:nil message:@"view hierarchy is invalid" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:kViewHiearchyIsInvalidNotification object:Nil userInfo:Nil];
            [[LogService sharedInstance] logEvent:@"view hierarchy is invalid" userInfo:Nil];
        }
        else {
            
            NSLog(@"view hiearchy seems to be valid");
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewDidApplearAtLeastOnce = YES;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    ACAccountStore *accountStore = appDelegate.accountStore;
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    self.accounts = accounts;
    
    //self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.accounts.count) {
        
        LoginController* loginController = [LoginController new];
        [self presentViewController:loginController animated:YES completion:NULL];
    }
    
    /*[UIView animateWithDuration:0.7 delay:0.5 options:0 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    } completion:NULL];*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    ACAccount* account = self.accounts[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", account.username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACAccount* account = self.accounts[indexPath.row];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account.username forKey:kUserDefaultsKeyUsername];
    [userDefaults synchronize];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UITabBarController* rootTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    rootTabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    
    WebControllerTransition* webTransition = [WebControllerTransition new];
    rootTabBarController.transitioningDelegate = webTransition;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:rootTabBarController animated:YES completion:NULL];

}

@end
