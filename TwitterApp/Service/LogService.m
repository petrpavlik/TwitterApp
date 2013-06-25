//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "LocalyticsSession.h"
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
        
        [[LocalyticsSession shared] startSession:@"3048d2b4028b670f856d4fc-f57032a8-d91f-11e2-0f5b-004a77f8b47f"];
        
        #ifdef DEBUG
        [[LocalyticsSession shared] setLoggingEnabled:YES];
        #endif
    }
    
    return self;
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event);
    [[LocalyticsSession shared] tagEvent:event attributes:userInfo];
}

+ (void)instatiate {
    [LogService sharedInstance];
}

@end
