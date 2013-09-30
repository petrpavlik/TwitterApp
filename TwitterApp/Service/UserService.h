//
//  UserService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 9/30/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserService : NSObject

@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* userId;

+ (UserService*)sharedInstance;

@end
