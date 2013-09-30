//
//  UserService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/30/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UserService.h"

@implementation UserService

+ (UserService*)sharedInstance {
    
    static UserService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UserService alloc] init];
    });
    
    return _sharedClient;
}


@end
