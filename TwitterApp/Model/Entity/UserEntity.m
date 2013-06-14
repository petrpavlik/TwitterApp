//
//  UserEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UserEntity.h"

@implementation UserEntity

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"IdStr"]) {
        
        self.userId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end
