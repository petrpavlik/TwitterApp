//
//  UserCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+TwitterApp.h"
#import "UserCell.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    UIView* contentView = self.contentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 5;
    [contentView addSubview:_avatarImageView];
    
    UIView* credentialsPlaceholder = [[UIView alloc] init];
    credentialsPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:credentialsPlaceholder];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [skin boldFontOfSize:16];
    _nameLabel.text = @"name";
    [credentialsPlaceholder addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _usernameLabel.font = [skin lightFontOfSize:15];
    _usernameLabel.text = @"username";
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_usernameLabel)]];
    
    [credentialsPlaceholder addConstraints:credentialsPlaceholderConstraints];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[credentialsPlaceholder]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
        
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_avatarImageView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:contentView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0]];

    
    [contentView addConstraints:superviewConstraints];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
}

@end
