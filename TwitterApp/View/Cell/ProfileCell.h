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

- (void)profileCellDidRequestChengeOfFriendship:(ProfileCell*)cell;
- (void)profileCell:(ProfileCell*)cell didSelectURL:(NSURL*)url;

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

- (void)setFollowedByStatus:(FollowedByStatus)status;

+ (CGFloat)requiredHeightWithDescription:(NSString*)description width:(CGFloat)width;

@end
