//
//  AppDelegate.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFNetworkActivityIndicatorManager.h>
#import "AFTwitterClient.h"
#import "AppDelegate.h"
#import "BaseEntity.h"
#import <ECSlidingViewController.h>
#import <HockeySDK/HockeySDK.h>
#import "LightSkin.h"
#import "LocalyticsSession.h"
#import "MentionsController.h"
#import "ModernSkin.h"
#import "MyProfileController.h"
#import "NavigationController.h"
#import "NetImageView.h"
#import <PocketAPI.h>
#import "SearchController.h"
#import "TimelineController.h"
#import "TwitterAppWindow.h"

@implementation AppDelegate

@synthesize skin = _skin;

- (UIWindow*)window {
    
    if (!_window) {
        _window = [[TwitterAppWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}

- (AbstractSkin*)skin {
    
    if (!_skin) {
        //_skin = [[LightSkin alloc] init];
        _skin = [[ModernSkin alloc] init];
    }
    
    return _skin;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"02ad5ad768997eb7c7878cb9791dad4b" delegate:Nil];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
#ifdef DEBUG
    [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
#endif

    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveNotification:) name:nil object:nil];
#endif
    
    UITabBarController* rootTabBarController = (UITabBarController*)self.window.rootViewController;
    rootTabBarController.tabBar.tintColor = self.skin.linkColor;
    
    TimelineController* timelineController = [[TimelineController alloc] init];
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
    UINavigationController* searchNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    searchNavigationController.restorationIdentifier = @"SearchNavigationController";
    searchNavigationController.viewControllers = @[searchController];

    
    MyProfileController* profileController = [MyProfileController new];
    profileController.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Profile"];
    profileController.tabBarItem.title = @"Profile";
    UINavigationController* profileNavigationController = [rootTabBarController.storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    profileNavigationController.restorationIdentifier = @"ProfileNavigationController";
    profileNavigationController.viewControllers = @[profileController];
    
    rootTabBarController.viewControllers = @[timelineNavigationController, mentionsNavigationController, searchNavigationController, profileNavigationController];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LogService instatiate];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[PocketAPI sharedAPI] handleOpenURL:url]) {
        
        return YES;
    } else {
        
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (UIViewController*)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {

    NSLog(@"AppDelegate: %@", identifierComponents);
    
    /*if ([identifierComponents.lastObject isEqual:@"UINavigationController"]) {
        return [[UINavigationController alloc] init];
    }*/
    
    return nil;
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark -

// Gets called only in debug state
- (void)applicationDidReceiveNotification:(NSNotification*)notification {
    //NSLog(@"%@", notification);
}

@end
