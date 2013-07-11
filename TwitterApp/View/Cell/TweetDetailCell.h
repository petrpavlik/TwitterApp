//
//  TweetDetailCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@class TweetDetailCell;

@protocol TweetDetailCellDelegate <NSObject>

- (void)tweetDetailCell:(TweetDetailCell*)cell didSelectURL:(NSURL*)url;
- (void)tweetDetailCell:(TweetDetailCell*)cell didSelectHashtag:(NSString*)hashstag;
- (void)tweetDetailCell:(TweetDetailCell*)cell didSelectMention:(NSString*)mention;
- (void)tweetDetailCell:(TweetDetailCell*)cell didLongPressURL:(NSURL*)url;
- (void)tweetDetailCellDidLongPress:(TweetDetailCell*)cell;
- (void)tweetDetailCellDidSelectAvatarImage:(TweetDetailCell*)cell;

- (void)tweetCellDidRequestFavorite:(TweetDetailCell*)cell;
- (void)tweetCellDidRequestOtherAction:(TweetDetailCell*)cell;
- (void)tweetCellDidRequestReply:(TweetDetailCell*)cell;
- (void)tweetCellDidRequestRetweet:(TweetDetailCell*)cell;

@end

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

@property(nonatomic, weak) id <TweetDetailCellDelegate> delegate;

@property(nonatomic, strong) UILabel* retweetedLabel;

@property(nonatomic) BOOL favoritedByUser;
@property(nonatomic) BOOL retweetedByUser;

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range;
- (void)addMention:(NSString*)mention atRange:(NSRange)range;
- (void)addURL:(NSURL*)url atRange:(NSRange)range;
+ (CGFloat)requiredHeightForTweetText:(NSString*)text;


@end
