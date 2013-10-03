//
//  AppDelegate.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "AFTwitterClient.h"
#import "AppDelegate.h"
#import "BaseEntity.h"
#import "LoginController.h"
#import "MentionsController.h"
#import "ModernSkin.h"
#import "MyProfileController.h"
#import "NavigationController.h"
#import "NetImageView.h"
#import <PocketAPI.h>
#import "SearchController.h"
#import "TimelineController.h"
#import "TwitterAppWindow.h"
#import "UserEntity.h"
#import "Base64.h"
#import "AFOAuth1Client.h"
#import <Crashlytics/Crashlytics.h>
#import "FollowTweetilusService.h"
#import "TwitterAccountsController.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

@synthesize skin = _skin;
@synthesize accountStore = _accountStore;

/*- (UIWindow*)window {
    
    if (!_window) {
        _window = [[TwitterAppWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}*/

- (AbstractSkin*)skin {
    
    if (!_skin) {
        //_skin = [[LightSkin alloc] init];
        _skin = [[ModernSkin alloc] init];
    }
    
    return _skin;
}

- (ACAccountStore*)accountStore {
    
    if (!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    return _accountStore;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //self.hub = [[SBNotificationHub alloc] initWithConnectionString: @"Endpoint=sb://tweetilus.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=X+WP16MQoASStF+zs1pu6gnwVO2LjC0pO2+7cBZwa0M=" notificationHubPath: @"https://tweetilus.servicebus.windows.net/tweetilus"];
    
    [Crashlytics startWithAPIKey:@"c8411cf93fbcb20e8dd6336cd727e16241dd5c68"];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    
    [BaseEntity setDictionaryToEntityKeyAdjusterBlock:^NSString *(NSString *key) {
        //converts keys such as created_at to CreatedAt
        
        if ([key rangeOfString:@"-"].location == NSNotFound && [key rangeOfString:@"_"].location == NSNotFound) {
            return [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] capitalizedString]];;
        }
        
        NSArray* components = [key componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-_"]];
        
        NSMutableString* outMutableString = [[NSMutableString alloc] init];
        
        for (NSString* component in components) {
            [outMutableString appendString:[component capitalizedString]];
        }
        
        return outMutableString;
    }];
    
    [NetImageView setSharedOperationQueue:[AFTwitterClient sharedClient].operationQueue];
    
    [self.skin applyGlobalAppearance];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [[PocketAPI sharedAPI] setConsumerKey:@"15055-3b898b85423c8af7f67ec331"];
    
#ifdef DEBUG
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveNotification:) name:nil object:nil];
#endif
    
    /*UITabBarController* rootTabBarController = (UITabBarController*)self.window.rootViewController;
    rootTabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    TimelineController* timelineController = [[TimelineController alloc] init];
    timelineController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Home"];
    timelineController.tabBarItem.title = @"Timeline";
    UINavigationController* timelineNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    timelineNavigationController.restorationIdentifier = @"TimelineNavigationController";
    timelineNavigationController.viewControllers = @[timelineController];
    
    MentionsController* mentionsController = [MentionsController new];
    mentionsController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Mentions"];
    mentionsController.tabBarItem.title = @"Mentions";
    UINavigationController* mentionsNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    mentionsNavigationController.restorationIdentifier = @"MentionsNavigationController";
    mentionsNavigationController.viewControllers = @[mentionsController];
    
    SearchController* searchController = [SearchController new];
    searchController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Search"];
    searchController.tabBarItem.title = @"Search";
    UINavigationController* searchNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    searchNavigationController.restorationIdentifier = @"SearchNavigationController";
    searchNavigationController.viewControllers = @[searchController];

    
    MyProfileController* profileController = [MyProfileController new];
    profileController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Profile"];
    profileController.tabBarItem.title = @"Profile";
    UINavigationController* profileNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    profileNavigationController.restorationIdentifier = @"ProfileNavigationController";
    profileNavigationController.viewControllers = @[profileController];
    
    rootTabBarController.viewControllers = @[timelineNavigationController, mentionsNavigationController, searchNavigationController, profileNavigationController];*/
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LogService instatiate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGainAccessToTwitterNotification:) name:kDidGainAccessToAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticatedUserDidLoadNotification:) name:kAuthenticatedUserDidLoadNotification object:nil];
    
    /*double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIView* rootControllerView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        if (![self isView:rootControllerView containedInHiearchyOfView:[UIApplication sharedApplication].keyWindow]) {
            
            [[[UIAlertView alloc] initWithTitle:@"Hierachy is broken" message:@"restoring default state" delegate:Nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
            self.window.rootViewController = [storyboard instantiateInitialViewController];
        }
    });*/
    
    /*ACAccountStore* accountStore = self.accountStore;
    ACAccountType* twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray* accounts = [accountStore accountsWithAccountType:twitterAccountType];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDefaults objectForKey:kUserDefaultsKeyUsername];
    
    if (accounts.count && username) {
        
        for (ACAccount* account in accounts) {
            
            if ([account.username isEqualToString:username]) {
                
                NSLog(@"found active account");
                [AFTwitterClient sharedClient].account = accounts.firstObject;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidGainAccessToAccountNotification object:nil];
                
                break;
            }
        }
    }*/
    
    /*NSString* selectorName = [NSString stringWithFormat:@"_%@%@%@%@:", @"set", @"Application", @"Is", @"Opaque"];
    SEL selector = NSSelectorFromString(selectorName);
    if ([application respondsToSelector:selector]) {
        [application performSelector:selector withObject:nil];
    }*/
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[LogService sharedInstance] logEvent:@"DidFinishLaunching" userInfo:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[LogService sharedInstance] logEvent:@"WillEnterForeground" userInfo:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[PocketAPI sharedAPI] handleOpenURL:url]) {
        
        return YES;
    } else {
        
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return YES;
        
        //return NO;
    }
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *restorationBundleVersion = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
    restorationBundleVersion = [restorationBundleVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if ([restorationBundleVersion integerValue] < 104)
    {
        NSLog(@"Ignoring restoration data for bundle version: %@",restorationBundleVersion);
        return NO;
    }
    return YES;
}

/*- (UIViewController*)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {

    NSLog(@"AppDelegate: %@", identifierComponents);
    
    return nil;
}*/

/*- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}*/

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"should perform fetch");
    
    /*ACAccount* account = [AFTwitterClient sharedClient].account;
    
    NSString* accountName = @"unknown";
    if (account.username) {
        accountName = account.username;
    }
    
    [[LogService sharedInstance] logEvent:@"background fetch requested" userInfo:@{@"Timestamp": [NSDate date].description, @"State": @(application.applicationState)}];*/
    
    if (self.tweetsControllerForBackgroundFetching) {
        
        TweetsController* timelineController = self.tweetsControllerForBackgroundFetching;
        [timelineController fetchNewTweetsWithCompletionHandler:completionHandler];
    }
    else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 
    NSLog(@"did obtain notification token");
    
    NSParameterAssert([UserEntity currentUser]);
    
    [self.hub registerNativeWithDeviceToken:deviceToken tags:[[NSSet alloc] initWithArray:@[[UserEntity currentUser].userId]] completion:^(NSError* error) {
        
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
        else {
            NSLog(@"token registered for azure");
        }
    }];
}*/

/*- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"did receive remote notification");
    
    NSString* notificationText = userInfo[@"aps"][@"alert"];
    
    [[[UIAlertView alloc] initWithTitle:@"Notification" message:notificationText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"did fail to obtain a notification token: %@", error);
}*/

#pragma mark -

// Gets called only in debug state
- (void)applicationDidReceiveNotification:(NSNotification*)notification {
    NSLog(@"%@", notification);
}

#pragma mark -

- (void)didGainAccessToTwitterNotification:(NSNotification*)notification {
    
}

- (void)authenticatedUserDidLoadNotification:(NSNotification*)notification {
    
    
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    //[[LogService sharedInstance] logEvent:@"user registered for remote notifications" userInfo:nil];
}

#pragma mark -

- (BOOL)isView:(UIView*)containedView containedInHiearchyOfView:(UIView*)containerView {

    for (UIView* view in containerView.subviews) {
        
        if (view == containedView) {
            return YES;
        }
        else {
            return [self isView:containedView containedInHiearchyOfView:view];
        }
    }
    
    return NO;
}


@end
