//
//  UserListController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListController : UITableViewController

@property(nonatomic, strong) NSString* tweetIdForRetweets;
@property(nonatomic, strong) NSString* tweetIdForFavorites;

@end
