//
//  AppDelegate.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AbstractSkin.h"
#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) AbstractSkin* skin;
@property (nonatomic, strong, readonly) ACAccountStore* accountStore;

@end
