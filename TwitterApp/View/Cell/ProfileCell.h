//
//  ProfileCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@class ProfileCell;

@protocol ProfileCellDelegate <NSObject>

- (void)profileCellDidRequestChengeOfFriendship:(ProfileCell*)cell;

@end

@interface ProfileCell : UITableViewCell

@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, weak) id <ProfileCellDelegate> delegate;
@property(nonatomic, strong) UILabel* descriptionLabel;
@property(nonatomic, strong) UIButton* followButton;
@property(nonatomic, strong) UIButton* locationButton;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* usernameLabel;
@property(nonatomic, strong) UIButton* websiteButton;

@end
