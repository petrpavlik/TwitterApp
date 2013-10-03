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
#import "AFTwitterClient.h"
#import "TimelineController.h"
#import "MentionsController.h"
#import "SearchController.h"
#import "MyProfileController.h"
#import "UserService.h"
#import "FollowTweetilusService.h"
#import "WebControllerTransition.h"

@interface TabBarController ()

@property(nonatomic) BOOL shouldBeDismissed;

@end

@implementation TabBarController

- (void)dealloc {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    ACAccountStore* accountStore = appDelegate.accountStore;
    ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray* accounts = [accountStore accountsWithAccountType:twitterAccountType];
    
    BOOL dismiss = NO;
    ACAccount* activeAccount = nil;
    
    if (!accounts.count) {
        dismiss = YES;
    }
    else {
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* username = [userDefaults objectForKey:kUserDefaultsKeyUsername];
        
        if (!username.length) {
            dismiss = YES;
        }
        else {
            
            dismiss = YES;
            
            for (ACAccount* account in accounts) {
                
                if ([account.username isEqualToString:username]) {
                    
                    dismiss = NO;
                    activeAccount = account;
                    break;
                }
            }
        }
    }
    
    if (dismiss) {
        
        self.shouldBeDismissed = YES;
    }
    else {
        
        [self constructTabs];
        
        [AFTwitterClient sharedClient].account = activeAccount;
        
        [UserService sharedInstance].username = activeAccount.username;
        [UserService sharedInstance].userId = [[[activeAccount valueForKey:@"properties"] valueForKey:@"user_id"] description];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidGainAccessToAccountNotification object:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldBeDismissed) {
        
        [self dismissViewControllerAnimated:YES completion:NULL];
        return;
    }
    
    [[FollowTweetilusService sharedInstance] offerFollowingIfAppropriate];
    
    for (UIViewController* tabViewController in self.viewControllers) {
        [tabViewController view];
    }
}

- (void)displayListOfAccounts {
    
    WebControllerTransition* webTransition = [WebControllerTransition new];
    webTransition.alreadyTransitioned = YES;
    self.transitioningDelegate = webTransition;
    self.presentingViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)constructTabs {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    TimelineController* timelineController = [[TimelineController alloc] init];
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
    
    self.viewControllers = @[timelineNavigationController, mentionsNavigationController, searchNavigationController, profileNavigationController];
}

@end
