//
//  UserTitleView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/29/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import <UIKit/UIKit.h>

@interface UserTitleView : UIView

@property(nonatomic, strong) NetImageView* avatarImageView;
@property(nonatomic, strong) UILabel* nameLabel;

@end
