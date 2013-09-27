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

@end

@implementation TwitterAccountsController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //self.navigationController.navigationBar.translucent = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    ACAccountStore *accountStore = appDelegate.accountStore;
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    self.accounts = accounts;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.accounts.count) {
        
        LoginController* loginController = [LoginController new];
        [self presentViewController:loginController animated:YES completion:NULL];
    }
    
    [UIView animateWithDuration:0.7 delay:0.5 options:0 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    } completion:NULL];
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
    
    /*ACAccount* account = self.accounts[indexPath.row];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account.username forKey:kUserDefaultsKeyUsername];
    [userDefaults synchronize];*/
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UITabBarController* rootTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    rootTabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    /*TimelineController* timelineController = [[TimelineController alloc] init];
    timelineController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Home"];
    timelineController.tabBarItem.title = @"Timeline";
    UINavigationController* timelineNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    timelineNavigationController.restorationIdentifier = @"TimelineNavigationController";
    timelineNavigationController.viewControllers = @[timelineController];
    
    MentionsController* mentionsController = [MentionsController new];
    mentionsController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Mentions"];
    mentionsController.tabBarItem.title = @"Mentions";
    UINavigationController* mentionsNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    mentionsNavigationController.restorationIdentifier = @"MentionsNavigationController";
    mentionsNavigationController.viewControllers = @[mentionsController];
    
    SearchController* searchController = [SearchController new];
    searchController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Search"];
    searchController.tabBarItem.title = @"Search";
    UINavigationController* searchNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    searchNavigationController.restorationIdentifier = @"SearchNavigationController";
    searchNavigationController.viewControllers = @[searchController];
    
    
    MyProfileController* profileController = [MyProfileController new];
    profileController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Profile"];
    profileController.tabBarItem.title = @"Profile";
    UINavigationController* profileNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    profileNavigationController.restorationIdentifier = @"ProfileNavigationController";
    profileNavigationController.viewControllers = @[profileController];
    
    rootTabBarController.viewControllers = @[timelineNavigationController, mentionsNavigationController, searchNavigationController, profileNavigationController];*/
    
    WebControllerTransition* webTransition = [WebControllerTransition new];
    rootTabBarController.transitioningDelegate = webTransition;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:rootTabBarController animated:YES completion:NULL];

}

@end
