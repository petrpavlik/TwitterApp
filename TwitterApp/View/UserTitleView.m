//
//  UserTitleView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/29/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UserTitleView.h"

@implementation UserTitleView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    UIView* centeredView = [UIView new];
    centeredView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:centeredView];
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.layer.cornerRadius = 12;
    _avatarImageView.clipsToBounds = YES;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.backgroundColor = [UIColor clearColor];
    
    [centeredView addSubview:_avatarImageView];
    [centeredView addSubview:_nameLabel];
    
    NSMutableArray* centeredViewConstraints = [NSMutableArray new];
    
    [centeredViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_avatarImageView(24)]-[_nameLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel)]];
    
    [centeredViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_avatarImageView(24)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel)]];
    
    [centeredView addConstraints:centeredViewConstraints];
    
    [centeredView centerInSuperview];
}

@end
