//
//  TweetDetailController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetEntity;

@interface TweetDetailController : UITableViewController

@property(nonatomic, strong) TweetEntity* tweet;

@end
