//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Mixpanel.h>
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
        
        [Mixpanel sharedInstanceWithToken:@"afb21c928464f8da1fe57a361c717980"]; //development
        //[Mixpanel sharedInstanceWithToken:@"d27510ad11c0999a393506059a035969"]; //production
    }
    
    return self;
}

- (void)logError:(NSError*)error {
    
    NSParameterAssert(error);
    
    NSLog(@"error: %@", error);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Error" properties:@{@"error": error.description}];
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event.length);
    
    NSLog(@"event: %@ userInfo: %@", event, userInfo);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:event properties:userInfo];
}

+ (void)instatiate {
    [LogService sharedInstance];
}

- (void)setUserId:(NSString*)userId {
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:userId];
    
    if (userId.length) {
        [mixpanel.people set:@{@"username": userId}];
    }
}

@end
