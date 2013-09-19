//
//  ProfileCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

typedef enum {
    kFollowedByStatusUnknown,
    kFollowedByStatusYes,
    kFollowedByStatusNo
} FollowedByStatus;

@class ProfileCell;

@protocol ProfileCellDelegate <NSObject>

- (void)profileCell:(ProfileCell*)cell didSelectURL:(NSURL*)url;
- (void)profileCellDidSelectLocation:(ProfileCell*)cell;
- (void)profileCellDidSelectAvatarImage:(ProfileCell *)cell;

- (void)profileCell:(ProfileCell *)cell didSelectHashtag:(NSString*)hashtag;
- (void)profileCell:(ProfileCell *)cell didSelectMention:(NSString*)mention;

@optional

- (void)profileCellDidRequestChengeOfFriendship:(ProfileCell*)cell;

@end

@interface ProfileCell : UITableViewCell

@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, weak) id <ProfileCellDelegate> delegate;
@property(nonatomic, strong) UILabel* descriptionLabel;
@property(nonatomic, strong) UIButton* followButton;
@property(nonatomic, strong) UILabel* followingLabel;
@property(nonatomic, strong) UIButton* locationButton;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* usernameLabel;
@property(nonatomic, strong) UIButton* websiteButton;
@property(nonatomic, strong) UILabel* lastTweetDateLabel;
@property(nonatomic, strong) UIActivityIndicatorView* activityIndicator;

- (void)setFollowedByStatus:(FollowedByStatus)status;
- (void)configureWithWebsiteAvailable:(BOOL)websiteAvailable locationAvailable:(BOOL)locationAvailable;

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range;
- (void)addMention:(NSString*)mention atRange:(NSRange)range;
- (void)addURL:(NSURL*)url atRange:(NSRange)range;

+ (CGFloat)requiredHeightWithDescription:(NSString*)description width:(CGFloat)width websiteAvailable:(BOOL)websiteAvailable locationAvailable:(BOOL)locationAvailable isMyProfile:(BOOL)isMyProfile;

@end
