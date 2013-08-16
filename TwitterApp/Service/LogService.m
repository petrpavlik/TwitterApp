//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "GAI.h"
#import "LogService.h"

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
        
        [GAI sharedInstance].trackUncaughtExceptions = NO;
        //[GAI sharedInstance].dispatchInterval = 20;
        
#ifdef DEBUG
        [GAI sharedInstance].debug = YES;
#endif
        // Create tracker instance.
        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-YOUR-TRACKING-ID"];
        
        
        
        [[GAI sharedInstance] defaultTracker] sendEventWithCategory:<#(NSString *)#> withAction:<#(NSString *)#> withLabel:<#(NSString *)#> withValue:<#(NSNumber *)#>
    }
    
    return self;
}

- (void)logError:(NSError*)error {
    
    NSParameterAssert(error);
    [Flurry logError:@"App Error" message:Nil error:error];
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event.length);
    if (userInfo) {
        [Flurry logEvent:event withParameters:userInfo];
    }
    else {
        [Flurry logEvent:event];
    }
}

+ (void)instatiate {
    [LogService sharedInstance];
}

- (void)setUserId:(NSString*)userId {
    
    [Flurry setUserID:userId];
}

@end
