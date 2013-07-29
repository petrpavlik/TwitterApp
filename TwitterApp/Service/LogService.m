//
//  LogService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "Flurry.h"
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
        
        [Flurry startSession:@"4KXXWFQNX9MYSFD52TJ5"];
        
        #ifdef DEBUG
        //[Flurry setDebugLogEnabled:YES];
        #endif
    }
    
    return self;
}

- (void)logError:(NSError*)error {
    
    NSParameterAssert(error);
    [Flurry logError:@"App Error" message:Nil error:error];
}

- (void)logEvent:(NSString *)event userInfo:(NSDictionary *)userInfo {
    
    NSParameterAssert(event.length);
    [Flurry logEvent:event withParameters:userInfo];
}

+ (void)instatiate {
    [LogService sharedInstance];
}

- (void)setUserId:(NSString*)userId {
    
    [Flurry setUserID:userId];
}

@end
