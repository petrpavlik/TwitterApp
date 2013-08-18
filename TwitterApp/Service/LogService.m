//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "GAI.h"
#import "LogService.h"

@interface LogService ()

@property(nonatomic, strong) id <GAITracker> tracker;

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
        
        [GAI sharedInstance].trackUncaughtExceptions = NO;
        [GAI sharedInstance].dispatchInterval = 0;
        
#ifdef DEBUG
        [GAI sharedInstance].debug = YES;
#endif
        // Create tracker instance.
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-43284408-1"];
        
        [self.tracker sendEventWithCategory:@"Tweetilus for iPhone" withAction:@"app launched" withLabel:Nil withValue:Nil];
    }
    
    return self;
}

- (void)logError:(NSError*)error {
    
    NSParameterAssert(error);
    //[Flurry logError:@"App Error" message:Nil error:error];
    [self.tracker sendException:NO withNSError:error];
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event.length);
    
    [self.tracker sendEventWithCategory:@"Tweetilus for iPhone" withAction:event withLabel:userInfo.description withValue:Nil];
}

+ (void)instatiate {
    [LogService sharedInstance];
}

- (void)setUserId:(NSString*)userId {
    
    [self.tracker set:@"userId" value:userId];
    //[Flurry setUserID:userId];
}

@end
