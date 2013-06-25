//
//  ProfileController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserEntity;

@interface ProfileController : UITableViewController

@property(nonatomic, strong) UserEntity* user;

@end
