//
//  TweetDetailCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetCell.h"
#import <UIKit/UIKit.h>

@class TweetDetailCell;

@interface TweetDetailCell : TweetCell

@property(nonatomic, strong) UILabel* locationLabel;
@property(nonatomic, strong) UILabel* createdWithLabel;

@end
