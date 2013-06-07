//
//  UserCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, strong) UILabel* nameLabel;
@property(nonatomic, strong) UILabel* usernameLabel;

@end
