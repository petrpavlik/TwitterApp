//
//  UIAlertView+TwitterApp.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/8/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UIAlertView+TwitterApp.h"
#import <objc/runtime.h>

#define kUserInfoIdentifier "userInfo"

@implementation UIAlertView (TwitterApp)

- (void)setUserInfo:(NSDictionary *)userInfo {
    
    objc_setAssociatedObject(self, &kUserInfoIdentifier, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary*)userInfo {
    return objc_getAssociatedObject(self, &kUserInfoIdentifier);
}

@end
