//
//  ProfileCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, strong) UIButton* followButton;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* usernameLabel;

@property(nonatomic, strong) UILabel* descriptionLabel;
@property(nonatomic, strong) UIButton* websiteButton;
@property(nonatomic, strong) UIButton* locationButton;

@end
