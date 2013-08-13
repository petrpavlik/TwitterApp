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
- (void)tweetCell:(TweetCell*)cell didSelectHashtag:(NSString*)hashstag;
- (void)tweetCell:(TweetCell*)cell didSelectMention:(NSString*)mention;
- (void)tweetCell:(TweetCell*)cell didLongPressURL:(NSURL*)url;
- (void)tweetCellDidLongPress:(TweetCell*)cell;
- (void)tweetCellDidSelectAvatarImage:(TweetCell*)cell;

- (void)tweetCellDidRequestFavorite:(TweetCell*)cell;
- (void)tweetCellDidRequestOtherAction:(TweetCell*)cell;
- (void)tweetCellDidRequestReply:(TweetCell*)cell;
- (void)tweetCellDidRequestRetweet:(TweetCell*)cell;

- (void)tweetCellDidScrollHorizontally:(TweetCell *)cell;

@end

@interface TweetCell : UITableViewCell

@property(nonatomic, strong) UILabel* actionLabel;
@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, weak) id <TweetCellDelegate> delegate;
@property(nonatomic, strong) NetImageView* mediaImageView;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UIButton* retweetedButton;
@property(nonatomic, strong) UILabel* tweetAgeLabel;
@property(nonatomic, strong) UILabel* tweetTextLabel;
@property(nonatomic, strong) UILabel* usernameLabel;

@property(nonatomic) BOOL favoritedByUser;
@property(nonatomic) BOOL retweetedByUser;

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range;
- (void)addMention:(NSString*)mention atRange:(NSRange)range;
- (void)addURL:(NSURL*)url atRange:(NSRange)range;
+ (CGFloat)requiredHeightForTweetText:(NSString*)text;

- (void)cancelAccessViewAnimated;

@end
