//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "LocalyticsSession.h"
#import "LogService.h"
#import "UserEntity.h"

@interface LogService ()

@end

@implementation LogService

+ (LogService*)sharedInstance {
    
    static LogService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[LogService alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        //[[LocalyticsSession shared] startSession:@"3048d2b4028b670f856d4fc-f57032a8-d91f-11e2-0f5b-004a77f8b47f"]; //development
        [[LocalyticsSession shared] startSession:@"a0dc225f0915b20687092d2-d6416024-1bf9-11e3-3b4e-00a426b17dd8"]; //production
        
#ifdef DEBUG
        [[LocalyticsSession shared] setLoggingEnabled:YES];
#endif
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingBackgroundNotification:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goingForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)logError:(NSError*)error {
    
    NSParameterAssert(error);
    
    NSLog(@"error: %@", error);
    
    UserEntity* currentUser = [UserEntity currentUser];
    if (currentUser) {
        
        [[LocalyticsSession shared] tagEvent:@"error" attributes:@{@"error": error, @"currentUser": currentUser.screenName}];
    }
    else {
     
        [[LocalyticsSession shared] tagEvent:@"error" attributes:@{@"error": error}];
    }
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event.length);
    
    UserEntity* currentUser = [UserEntity currentUser];
    if (currentUser) {
        
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        if (!mutableUserInfo) {
            mutableUserInfo = [NSMutableDictionary new];
        }
        
        mutableUserInfo[@"currentUser"] = currentUser.screenName;
        
        userInfo = mutableUserInfo;
    }
    
    NSLog(@"event: %@ userInfo: %@", event, userInfo);
    
    [[LocalyticsSession shared] tagEvent:event attributes:userInfo];
}

+ (void)instatiate {
    [LogService sharedInstance];
}

- (void)setUserId:(NSString*)userId {
    
    [[LocalyticsSession shared] setCustomerId:userId];
    [[LocalyticsSession shared] setCustomerName:userId];
}

#pragma mark -

- (void)goingBackgroundNotification:(NSNotification*)notification {
    
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)goingForegroundNotification:(NSNotification*)notificaiton {
    
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
}

@end
