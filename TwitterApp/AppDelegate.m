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
#import "LightSkin.h"
#import "NavigationController.h"
#import "NetImageView.h"
#import <PocketAPI.h>
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
        _skin = [[LightSkin alloc] init];
    }
    
    return _skin;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    ECSlidingViewController* rootController = (ECSlidingViewController*)self.window.rootViewController;
    rootController.view.backgroundColor = [UIColor blackColor];
    TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    
    rootController.topViewController = [[NavigationController alloc] initWithRootViewController:timelineController];
    
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
        
        return NO;
    }
}

@end
