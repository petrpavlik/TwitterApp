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
#import "PersistentBackgroundColorView.h"

@interface UserCell ()

@property(nonatomic, strong) id textSizeChangedObserver;

@end

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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

- (void)commonSetup {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    UIView* contentView = self.contentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_avatarImageView.clipsToBounds = YES;
    //_avatarImageView.layer.cornerRadius = 5;
    _avatarImageView.tintColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    _avatarImageView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:_avatarImageView];
    
    UIView* credentialsPlaceholder = [[UIView alloc] init];
    credentialsPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:credentialsPlaceholder];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_nameLabel.font = [skin boldFontOfSize:16];
    _nameLabel.text = @"name";
    _nameLabel.backgroundColor = [UIColor whiteColor];
    [credentialsPlaceholder addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_usernameLabel.font = [skin fontOfSize:15];
    _usernameLabel.text = @"username";
    _usernameLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    _usernameLabel.backgroundColor = [UIColor whiteColor];
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    _verifiedImageView = [[UIImageView alloc] init];
    _verifiedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _verifiedImageView.tintColor = appDelegate.skin.linkColor;
    _verifiedImageView.hidden = YES;
    _verifiedImageView.backgroundColor = [UIColor whiteColor];
    [credentialsPlaceholder addSubview:_verifiedImageView];
    
    UIImage* verifiedImage = [[UIImage imageNamed:@"Icon-Verified"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _verifiedImageView.image = verifiedImage;
    
    PersistentBackgroundColorView* separatorView = [[PersistentBackgroundColorView alloc] init];
    [separatorView setPersistentBackgroundColor:[UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1]];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:separatorView];
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]-4-[_verifiedImageView]->=15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _verifiedImageView)]];
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
                                                                constant:-1]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-64-[separatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(0.5)]-0.5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];


    
    [contentView addConstraints:superviewConstraints];
    
    [self setupFonts];
    
    __weak typeof(self) weakSelf = self;
    
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf setupFonts];
    }];
    
}

- (void)setupFonts {
    
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
    self.verifiedImageView.hidden = YES;
}

@end
