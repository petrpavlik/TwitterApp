//
//  TweetCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* usernameLabel;
@property(nonatomic, strong) UILabel* tweetAgeLabel;
@property(nonatomic, strong) UILabel* tweetTextLabel;
@property(nonatomic, strong) UILabel* actionLabel;

@end
