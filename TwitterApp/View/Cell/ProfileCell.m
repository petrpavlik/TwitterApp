//
//  ProfileCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileCell.h"
#import "UIImage+TwitterApp.h"

@implementation ProfileCell

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    self.tintColor = skin.linkColor;
    
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = [skin linkColor];
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    UIView* contentView = self.contentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_avatarImageView];
    
    UIView* credentialsPlaceholder = [[UIView alloc] init];
    credentialsPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:credentialsPlaceholder];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [skin boldFontOfSize:16];
    //_nameLabel.text = @"name";
    [credentialsPlaceholder addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_usernameLabel.font = [skin fontOfSize:15];
    _usernameLabel.text = @"username";
    _usernameLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    _followButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _followButton.translatesAutoresizingMaskIntoConstraints = NO;
    _followButton.titleLabel.font = [skin fontOfSize:16];
    [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [_followButton addTarget:self action:@selector(friendshipButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_followButton];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_descriptionLabel.font = [skin fontOfSize:15];
    _descriptionLabel.text = @"description";
    _descriptionLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.numberOfLines = 0;
    [contentView addSubview:_descriptionLabel];
    
    _websiteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _websiteButton.translatesAutoresizingMaskIntoConstraints = NO;
    _websiteButton.titleLabel.font = [skin fontOfSize:16];
    [_websiteButton addTarget:self action:@selector(websiteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_websiteButton];
    
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    //_locationButton.titleLabel.font = [skin fontOfSize:16];
    [_locationButton setTitle:@"fsfs" forState:UIControlStateNormal];
    [contentView addSubview:_locationButton];
    
    UIImageView* separatorView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1] size:CGSizeMake(1, 1)]];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:separatorView];
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_usernameLabel)]];
    
    [credentialsPlaceholder addConstraints:credentialsPlaceholderConstraints];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_avatarImageView(48)]-[credentialsPlaceholder]->=8-[_followButton]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder, _followButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_descriptionLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-20-[_descriptionLabel]-20-[_websiteButton][_locationButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel, _avatarImageView, _websiteButton, _locationButton)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_websiteButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_locationButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_avatarImageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    
    [contentView addConstraints:superviewConstraints];
    
    [self prepareForReuse];
    
    [self setupFonts];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
    self.followButton.hidden = YES;
    self.followButton.selected = NO;
}

- (void)friendshipButtonSelected {
    [self.delegate profileCellDidRequestChengeOfFriendship:self];
}

- (void)websiteButtonSelected:(UIButton*)sender {
    
    [self.delegate profileCell:self didSelectURL:[NSURL URLWithString:[sender titleForState:UIControlStateNormal]]];
}

- (void)setupFonts {
    
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _websiteButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _locationButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

+ (CGFloat)requiredHeightWithDescription:(NSString*)description width:(CGFloat)width {
    
    CGFloat textHeight = [description boundingRectWithSize:CGSizeMake(width-20-20, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height;
    
    CGFloat height = 170 + textHeight + 20;
    
    return height;
}

@end
