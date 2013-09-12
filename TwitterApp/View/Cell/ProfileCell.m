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
#import "PPLabel.h"

@interface ProfileCell () <PPLabelDelegate>

@property(nonatomic, strong) NSArray* websiteAndLocationConstrains;
@property(nonatomic, strong) NSArray* websiteNoLocationConstraints;
@property(nonatomic, strong) NSArray* locationNoWebsiteConstraints;
@property(nonatomic, strong) NSArray* noWebsiteNoLocationConstraints;

@property(nonatomic, strong) NSMutableDictionary* urlsDictonary;
@property(nonatomic, strong) NSMutableDictionary* hashtagsDictonary;
@property(nonatomic, strong) NSMutableDictionary* mentionsDictonary;

@property(nonatomic, strong) id textSizeChangedObserver;

@end

@implementation ProfileCell

- (NSMutableDictionary*)urlsDictonary {
    
    if (!_urlsDictonary) {
        _urlsDictonary = [NSMutableDictionary new];
    }
    
    return _urlsDictonary;
}

- (NSMutableDictionary*)hashtagsDictonary {
    
    if (!_hashtagsDictonary) {
        _hashtagsDictonary = [NSMutableDictionary new];
    }
    
    return _hashtagsDictonary;
}

- (NSMutableDictionary*)mentionsDictonary {
    
    if (!_mentionsDictonary) {
        _mentionsDictonary = [NSMutableDictionary new];
    }
    
    return _mentionsDictonary;
}

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
    _avatarImageView.tintColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    [contentView addSubview:_avatarImageView];
    
    _avatarImageView.userInteractionEnabled = YES;
    [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarSelected)]];
    
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
    _usernameLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    _followButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _followButton.translatesAutoresizingMaskIntoConstraints = NO;
    _followButton.titleLabel.font = [skin fontOfSize:16];
    [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [_followButton addTarget:self action:@selector(friendshipButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_followButton];
    
    _descriptionLabel = [PPLabel new];
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionLabel.text = @"description";
    _descriptionLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.numberOfLines = 0;
    [contentView addSubview:_descriptionLabel];
    
    PPLabel* descriptionLabel = (PPLabel*)_descriptionLabel;
    descriptionLabel.delegate = self;
    
    _lastTweetDateLabel = [UILabel new];
    _lastTweetDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lastTweetDateLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    _lastTweetDateLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_lastTweetDateLabel];
    
    _websiteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _websiteButton.translatesAutoresizingMaskIntoConstraints = NO;
    _websiteButton.titleLabel.font = [skin fontOfSize:16];
    [_websiteButton setImage:[UIImage imageNamed:@"Btn-Web"] forState:UIControlStateNormal];
    [_websiteButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_websiteButton addTarget:self action:@selector(websiteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_websiteButton];
    
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    //_locationButton.titleLabel.font = [skin fontOfSize:16];
    [_locationButton setTitle:@"fsfs" forState:UIControlStateNormal];
    [_locationButton setImage:[UIImage imageNamed:@"Btn-Location"] forState:UIControlStateNormal];
    [_locationButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_locationButton addTarget:self action:@selector(locationButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_locationButton];
    
    _followingLabel = [UILabel new];
    _followingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _followingLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:_followingLabel];
    
    /*UIView* separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:separatorView];*/
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_usernameLabel)]];
    
    [credentialsPlaceholder addConstraints:credentialsPlaceholderConstraints];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_avatarImageView(48)]-[credentialsPlaceholder]->=8-[_followButton]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder, _followButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_descriptionLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_followingLabel]-[_lastTweetDateLabel]-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_followingLabel, _lastTweetDateLabel)]];
    
    self.websiteAndLocationConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-20-[_descriptionLabel]-20-[_websiteButton(44)][_locationButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel, _avatarImageView, _websiteButton, _locationButton)];
    self.websiteNoLocationConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-20-[_descriptionLabel]-20-[_websiteButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel, _avatarImageView, _websiteButton, _locationButton)];
    self.locationNoWebsiteConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-20-[_descriptionLabel]-20-[_locationButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel, _avatarImageView, _websiteButton, _locationButton)];
    self.noWebsiteNoLocationConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-20-[_descriptionLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_descriptionLabel, _avatarImageView, _websiteButton, _locationButton)];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_followingLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_followingLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_websiteButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_websiteButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_locationButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_locationButton)]];
    
    
    
    /*[superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_websiteButton
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
                                                                  constant:0]];*/
    
    /*[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[separatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];*/
    
    
    [contentView addConstraints:superviewConstraints];
    
    [self prepareForReuse];
    
    [self setupFonts];
    
    __weak typeof(self) weakSelf = self;
    
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf setupFonts];
    }];

    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
    self.followButton.hidden = YES;
    self.followButton.selected = NO;
    
    [self.urlsDictonary removeAllObjects];
    [self.hashtagsDictonary removeAllObjects];
    [self.mentionsDictonary removeAllObjects];
}

- (void)friendshipButtonSelected {
    [self.delegate profileCellDidRequestChengeOfFriendship:self];
}

- (void)websiteButtonSelected:(UIButton*)sender {
    
    [self.delegate profileCell:self didSelectURL:[NSURL URLWithString:[sender titleForState:UIControlStateNormal]]];
}

- (void)locationButtonSelected:(UIButton*)sender {
    
    [self.delegate profileCellDidSelectLocation:self];
}

- (void)setupFonts {
    
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _websiteButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _locationButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _followingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _lastTweetDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

+ (CGFloat)requiredHeightWithDescription:(NSString*)description width:(CGFloat)width websiteAvailable:(BOOL)websiteAvailable locationAvailable:(BOOL)locationAvailable {
    
    CGFloat textHeight = [description boundingRectWithSize:CGSizeMake(width-20-20, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height;
    
    CGFloat height = 170 + textHeight + 20 + 15 + 15;
    
    if (!websiteAvailable) {
        height -= 44;
    }
    
    if (!locationAvailable) {
        height -= 44;
    }
    
    return height;
}

- (void)setFollowedByStatus:(FollowedByStatus)status {
    
    if (status == kFollowedByStatusUnknown) {
        self.followingLabel.text = nil;
    }
    else if (status == kFollowedByStatusYes) {
        self.followingLabel.text = @"Following you";
        self.followingLabel.textColor = [UIColor blackColor];
    }
    else if (status == kFollowedByStatusNo) {
        self.followingLabel.text = @"Not following you";
        self.followingLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    }
}

- (void)avatarSelected {
    [self.delegate profileCellDidSelectAvatarImage:self];
}

- (void)configureWithWebsiteAvailable:(BOOL)websiteAvailable locationAvailable:(BOOL)locationAvailable {
    
    [self.contentView removeConstraints:self.websiteAndLocationConstrains];
    [self.contentView removeConstraints:self.websiteNoLocationConstraints];
    [self.contentView removeConstraints:self.locationNoWebsiteConstraints];
    [self.contentView removeConstraints:self.noWebsiteNoLocationConstraints];
    
    if (websiteAvailable && locationAvailable) {
        [self.contentView addConstraints:self.websiteAndLocationConstrains];
    }
    else if (websiteAvailable && !locationAvailable) {
        [self.contentView addConstraints:self.websiteNoLocationConstraints];
    }
    else if (!websiteAvailable && locationAvailable) {
        [self.contentView addConstraints:self.locationNoWebsiteConstraints];
    }
    else if (!websiteAvailable && !locationAvailable) {
        [self.contentView addConstraints:self.noWebsiteNoLocationConstraints];
    }
}

#pragma mark -

- (void)addURL:(NSURL*)url atRange:(NSRange)range {
    
    NSParameterAssert(url);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.descriptionLabel.attributedText = attributedString;
    
    self.urlsDictonary[[NSValue valueWithRange:range]] = url;
}

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range {
    
    NSParameterAssert(hashtag);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.descriptionLabel.attributedText = attributedString;
    
    self.hashtagsDictonary[[NSValue valueWithRange:range]] = hashtag;
    
}

- (void)addMention:(NSString*)mention atRange:(NSRange)range {
    
    NSParameterAssert(mention);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.descriptionLabel.attributedText = attributedString;
    
    self.mentionsDictonary[[NSValue valueWithRange:range]] = mention;
    
}

#pragma mark -

- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:
             [NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
            
            self.descriptionLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.descriptionLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.descriptionLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    return NO;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.descriptionLabel.attributedText = attributedString;
            
            [self.delegate profileCell:self didSelectURL:self.urlsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.descriptionLabel.attributedText = attributedString;
            
            [self.delegate profileCell:self didSelectHashtag:self.hashtagsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.descriptionLabel.attributedText = attributedString;
            
            [self.delegate profileCell:self didSelectMention:self.mentionsDictonary[rangeValue]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    NSMutableAttributedString* attributedString = [self.descriptionLabel.attributedText mutableCopy];
    [attributedString removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, attributedString.length)];
    self.descriptionLabel.attributedText = attributedString;
    
    return NO;
}

@end
