//
//  TweetDetailCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@interface TweetDetailCell : UITableViewCell

@property(nonatomic, strong) UILabel* actionLabel;
@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, strong) UILabel* createdWithLabel;
@property(nonatomic, strong) UILabel* locationLabel;
@property(nonatomic, strong) NetImageView* mediaImageView;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UIButton* numFavoritesButton;
@property(nonatomic, strong) UIButton* numRetweetsButton;
@property(nonatomic, strong) UILabel* tweetAgeLabel;
@property(nonatomic, strong) UILabel* tweetTextLabel;
@property(nonatomic, strong) UILabel* usernameLabel;

@end
