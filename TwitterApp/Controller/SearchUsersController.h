//
//  SearchUsersController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUsersController : UITableViewController

@property(nonatomic, readonly) UIView* notificationViewPlaceholderView;
@property(nonatomic, strong) NSString* searchQuery;

@end
