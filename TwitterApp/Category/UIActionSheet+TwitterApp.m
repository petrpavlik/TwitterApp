//
//  UIActionSheet+TwitterApp.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/9/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UIActionSheet+TwitterApp.h"
#import <objc/runtime.h>

#define kUserInfoIdentifier "userInfo"

@implementation UIActionSheet (TwitterApp)

- (void)setUserInfo:(NSDictionary *)userInfo {
    
    objc_setAssociatedObject(self, &kUserInfoIdentifier, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary*)userInfo {
    return objc_getAssociatedObject(self, &kUserInfoIdentifier);
}

@end
