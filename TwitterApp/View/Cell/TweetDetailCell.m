//
//  TweetDetailCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "PPLabel.h"
#import "TweetDetailCell.h"
#import "UIImage+TwitterApp.h"

@interface TweetDetailCell ()

@property(nonatomic, strong) UIGestureRecognizer* cellLongPressGestureRecognizer;
@property(nonatomic, strong) NSMutableDictionary* urlsDictonary;
@property(nonatomic, strong) NSMutableDictionary* hashtagsDictonary;
@property(nonatomic, strong) NSMutableDictionary* mentionsDictonary;

@property(nonatomic, strong) NSTimer* linkLongPressTimer;

@property(nonatomic, strong) UIButton* favoriteButton;
@property(nonatomic, strong) UIButton* retweetButton;


@end

@implementation TweetDetailCell

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

- (void)setRetweetedByUser:(BOOL)retweetedByUser {
    
    _retweetedByUser = retweetedByUser;
    self.retweetButton.selected = retweetedByUser;
}

- (void)setFavoritedByUser:(BOOL)favoritedByUser {
    
    _favoritedByUser = favoritedByUser;
    self.favoriteButton.selected = favoritedByUser;
}

#pragma mark -

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonSetup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
    
    [self.urlsDictonary removeAllObjects];
    _retweetedLabel.text = nil;
    
    [self.urlsDictonary removeAllObjects];
    [self.hashtagsDictonary removeAllObjects];
    [self.mentionsDictonary removeAllObjects];
}

+ (CGFloat)requiredHeightForTweetText:(NSString*)text {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    CGFloat textHeight = [text sizeWithFont:[skin fontOfSize:16] constrainedToSize:CGSizeMake(240, FLT_MAX)].height;
    
    CGFloat height = 10 + 16 + 15 + 5 + textHeight + 10 + 44 + 15;
    
    return height;
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
    //_avatarImageView.clipsToBounds = YES;
    //_avatarImageView.layer.cornerRadius = 5;
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
    _usernameLabel.font = [skin fontOfSize:15];
    _usernameLabel.text = @"username";
    _usernameLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    _tweetTextLabel = [[PPLabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    _tweetTextLabel.font = [skin fontOfSize:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    _tweetAgeLabel = [[UILabel alloc] init];
    _tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    _tweetAgeLabel.font = [skin fontOfSize:15];
    _tweetAgeLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    _tweetAgeLabel.text = @"1d";
    [contentView addSubview:_tweetAgeLabel];
    
    UIView* controlsView = [self createControlsView];
    controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:controlsView];
    
    _createdWithLabel = [[UILabel alloc] init];
    _createdWithLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _createdWithLabel.textAlignment = NSTextAlignmentRight;
    _createdWithLabel.font = [skin fontOfSize:15];
    _createdWithLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    [contentView addSubview:_createdWithLabel];
    
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _locationLabel.font = [skin fontOfSize:15];
    _locationLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    [contentView addSubview:_locationLabel];
    
    UIImageView* separatorView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1] size:CGSizeMake(1, 1)]];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:separatorView];
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_usernameLabel)]];
    
    [credentialsPlaceholder addConstraints:credentialsPlaceholderConstraints];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[credentialsPlaceholder]-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder, _tweetAgeLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[credentialsPlaceholder]-5-[_tweetTextLabel]-10-[controlsView]-[_locationLabel]" options:NSLayoutFormatAlignAllLeading metrics:nil views:NSDictionaryOfVariableBindings(credentialsPlaceholder, _tweetTextLabel, controlsView, _locationLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tweetTextLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_locationLabel]-[_createdWithLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationLabel, _createdWithLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[controlsView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(controlsView)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_tweetTextLabel
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
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [contentView addGestureRecognizer:longPressRecognizer];
    self.cellLongPressGestureRecognizer = longPressRecognizer;
}

#pragma mark -

- (UIView*)createControlsView {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    UIView* controlsView = [UIView new];
    
    controlsView.tintColor = skin.linkColor;
    
    UIButton* replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [replyButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Reply"] forState:UIControlStateNormal];
    [replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    replyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:replyButton];
    
    UIButton* retweetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [retweetButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Retweet"] forState:UIControlStateNormal];
    [retweetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    retweetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:retweetButton];
    
    UIButton* favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [favoriteButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Favorite"] forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:favoriteButton];
    
    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [otherButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Other"] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    otherButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:otherButton];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[replyButton][retweetButton(replyButton)][favoriteButton(replyButton)][otherButton(replyButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[replyButton(44)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(replyButton)]];
    
    [controlsView addConstraints:superviewConstraints];
    
    return controlsView;
}

#pragma mark -

#pragma mark -

- (void)addURL:(NSURL*)url atRange:(NSRange)range {
    
    NSParameterAssert(url);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.urlsDictonary[[NSValue valueWithRange:range]] = url;
}

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range {
    
    NSParameterAssert(hashtag);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.hashtagsDictonary[[NSValue valueWithRange:range]] = hashtag;
    
}

- (void)addMention:(NSString*)mention atRange:(NSRange)range {
    
    NSParameterAssert(mention);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.mentionsDictonary[[NSValue valueWithRange:range]] = mention;
    
}

#pragma mark -

- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:
             [NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
            
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.linkLongPressTimer invalidate];
            self.linkLongPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(linkLongPressTimerDidFire:) userInfo:@{@"URL": self.urlsDictonary[rangeValue]} repeats:NO];
            
            self.cellLongPressGestureRecognizer.enabled = NO;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    return NO;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self.linkLongPressTimer invalidate];
    self.linkLongPressTimer = nil;
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetDetailCell:self didSelectURL:self.urlsDictonary[rangeValue]];
            self.cellLongPressGestureRecognizer.enabled = YES;
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetDetailCell:self didSelectHashtag:self.hashtagsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetDetailCell:self didSelectMention:self.mentionsDictonary[rangeValue]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self.linkLongPressTimer invalidate];
    self.linkLongPressTimer = nil;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, attributedString.length)];
    self.tweetTextLabel.attributedText = attributedString;
    
    self.cellLongPressGestureRecognizer.enabled = YES;
    
    return NO;
}

#pragma mark -

- (void)replySelected {
    
    [self.delegate tweetCellDidRequestReply:self];
}

- (void)retweetSelected {
    [self.delegate tweetCellDidRequestRetweet:self];
}

- (void)favoriteSelected {
    [self.delegate tweetCellDidRequestFavorite:self];
}

- (void)otherActionSelected {
    [self.delegate tweetCellDidRequestOtherAction:self];
}

#pragma mark -

- (void)avatarSelected {
    [self.delegate tweetDetailCellDidSelectAvatarImage:self];
}

- (void)linkLongPressTimerDidFire:(NSTimer*)timer {
    
    self.linkLongPressTimer = nil;
    
    PPLabel* textLabel = (PPLabel*)self.tweetTextLabel;
    [textLabel cancelCurrentTouch];
    
    [self.delegate tweetDetailCell:self didLongPressURL:timer.userInfo[@"URL"]];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer*)gestureRecognizer {
    
    NSLog(@"%@", gestureRecognizer);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate tweetDetailCellDidLongPress:self];
    }
}


@end
