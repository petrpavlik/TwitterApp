//
//  TweetCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)tweetCell:(TweetCell*)cell didSelectURL:(NSURL*)url;

@end

@interface TweetCell : UITableViewCell

@property(nonatomic, strong) UILabel* actionLabel;
@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, weak) id <TweetCellDelegate> delegate;
@property(nonatomic, strong) NetImageView* mediaImageView;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* retweetedLabel;
@property(nonatomic, strong) UILabel* tweetAgeLabel;
@property(nonatomic, strong) UILabel* tweetTextLabel;
@property(nonatomic, strong) UILabel* usernameLabel;

- (void)addURL:(NSURL*)url atRange:(NSRange)range;
+ (CGFloat)requiredHeightForTweetText:(NSString*)text;

@end
