//
//  TweetCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "PPLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "TweetCell.h"

@interface TweetCell () <PPLabelDelegate>

@property(nonatomic, strong) NSMutableDictionary* urlsDictonary;
@property(nonatomic, strong) NSMutableDictionary* hashtagsDictonary;
@property(nonatomic, strong) NSMutableDictionary* mentionsDictonary;
@property(nonatomic, strong) UIView* slidingContentView;
@property(nonatomic, strong) UIImageView* rightActionImageView;
@property(nonatomic, strong) UIImageView* leftActionImageView;
@property(nonatomic, strong) NSTimer* linkLongPressTimer;

@end

@implementation TweetCell

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

- (void)commonSetup {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    _slidingContentView = [[UIView alloc] init];
    [self.contentView addSubview:_slidingContentView];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureMoveAround:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [_slidingContentView addGestureRecognizer:panGesture];
    
    UIView* contentView = _slidingContentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 5;
    
    [contentView addSubview:_avatarImageView];
    
    UITapGestureRecognizer* avatarTapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarSelected)];
    [_avatarImageView addGestureRecognizer:avatarTapGestureRecongnizer];
    _avatarImageView.userInteractionEnabled = YES;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [skin boldFontOfSize:16];
    _nameLabel.text = @"name";
    [contentView addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_usernameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _usernameLabel.font = [skin lightFontOfSize:15];
    _usernameLabel.text = @"username";
    [contentView addSubview:_usernameLabel];
    
    _retweetedLabel = [[UILabel alloc] init];
    _retweetedLabel.font = [skin lightFontOfSize:15];
    _retweetedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_retweetedLabel];
    
    _tweetAgeLabel = [[UILabel alloc] init];
    _tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    _tweetAgeLabel.font = [skin lightFontOfSize:15];
    _tweetAgeLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    _tweetAgeLabel.text = @"1d";
    [contentView addSubview:_tweetAgeLabel];
    
    _tweetTextLabel = [[PPLabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    _tweetTextLabel.font = [skin fontOfSize:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    PPLabel* tweetTextLabel = (PPLabel*)_tweetTextLabel;
    tweetTextLabel.delegate = self;
    
    _mediaImageView = [[NetImageView alloc] init];
    _mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    _mediaImageView.clipsToBounds = YES;
    [contentView addSubview:_mediaImageView];
    
    _rightActionImageView = [[UIImageView alloc] init];
    _rightActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _rightActionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _rightActionImageView.image = [UIImage imageNamed:@"Icon-Retweet-Normal"];
    [contentView addSubview:_rightActionImageView];
    
    _leftActionImageView = [[UIImageView alloc] init];
    _leftActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _leftActionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _leftActionImageView.image = [UIImage imageNamed:@"Icon-Reply-Normal"];
    [contentView addSubview:_leftActionImageView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[_nameLabel]-[_usernameLabel]-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel, _usernameLabel, _tweetAgeLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-1-[_tweetTextLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mediaImageView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tweetTextLabel][_retweetedLabel]-[_mediaImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView, _tweetTextLabel, _retweetedLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tweetTextLabel(240)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarImageView]-[_retweetedLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _tweetTextLabel, _retweetedLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tweetAgeLabel]-20-[_rightActionImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rightActionImageView, _tweetAgeLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_leftActionImageView]-20-[_avatarImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftActionImageView, _avatarImageView)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_rightActionImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_leftActionImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];

    
    [contentView addConstraints:superviewConstraints];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [contentView addGestureRecognizer:longPressRecognizer];
}

#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.urlsDictonary removeAllObjects];
    _retweetedLabel.text = nil;
    
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.origin.x = -50;
    self.contentView.frame = contentViewFrame;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _slidingContentView.frame = self.contentView.bounds;
}

#pragma mark -

+ (CGFloat)requiredHeightForTweetText:(NSString*)text {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    CGFloat textHeight = [text sizeWithFont:[skin fontOfSize:16] constrainedToSize:CGSizeMake(240, FLT_MAX)].height;
    
    CGFloat height = 10 + 16 + 1 + textHeight + 10 + 2;
    
    if (height < 70) {
        return 70;
    }
    else {
        return height;
    }
}

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
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectURL:self.urlsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectHashtag:self.hashtagsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectMention:self.mentionsDictonary[rangeValue]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self.linkLongPressTimer invalidate];
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, attributedString.length)];
    self.tweetTextLabel.attributedText = attributedString;
    
    return NO;
}

#pragma mark -

-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    UIView *contentView = [gesture view];
    //[self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        [self setSelected:NO animated:YES];
        
        //CGPoint translation = [gesture translationInView:[piece superview]];
        CGPoint velocity = [gesture velocityInView:[contentView superview]];
        
        CGFloat frictionCoefficient = abs(contentView.frame.origin.x)*0.05;
        if (frictionCoefficient < 1) {
            frictionCoefficient = 1;
        }
        
        contentView.center = CGPointMake(contentView.center.x + velocity.x/(60*frictionCoefficient), contentView.center.y);
        
        if (contentView.frame.origin.x < -50) {
            
            _leftActionImageView.image = [UIImage imageNamed:@"Icon-Reply-Normal"];
            _rightActionImageView.image = [UIImage imageNamed:@"Icon-Retweet-Highlighted"];
        }
        else if (contentView.frame.origin.x > 50) {
            
            _leftActionImageView.image = [UIImage imageNamed:@"Icon-Reply-Highlighted"];
            _rightActionImageView.image = [UIImage imageNamed:@"Icon-Retweet-Normal"];
        }
        else {
            
            _leftActionImageView.image = [UIImage imageNamed:@"Icon-Reply-Normal"];
            _rightActionImageView.image = [UIImage imageNamed:@"Icon-Retweet-Normal"];
        }
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded || [gesture state] == UIGestureRecognizerStateCancelled) {
        
        if (contentView.frame.origin.x < -50) {
            
            NSLog(@"right action triggered");
            [self.delegate tweetCellDidRequestRightAction:self];
        }
        else if (contentView.frame.origin.x > 50) {
            
            NSLog(@"left action triggered");
            [self.delegate tweetCellDidRequestLeftAction:self];
        }
        
        CGFloat animationSpeed = abs(contentView.frame.origin.x)*0.002;
        
        [UIView animateWithDuration:animationSpeed animations:^{
            contentView.center = CGPointMake(self.contentView.center.x, contentView.center.y);
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:[[gestureRecognizer view] superview] ];
        return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
    }

    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark -

- (void)avatarSelected {
    [self.delegate tweetCellDidSelectAvatarImage:self];
}

- (void)linkLongPressTimerDidFire:(NSTimer*)timer {
    
    self.linkLongPressTimer = nil;
    
    PPLabel* textLabel = (PPLabel*)self.tweetTextLabel;
    [textLabel cancelCurrentTouch];
    
    [self.delegate tweetCell:self didLongPressURL:timer.userInfo[@"URL"]];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer*)gestureRecognizer {
    
    NSLog(@"%@", gestureRecognizer);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate tweetCellDidLongPress:self];
    }
}

@end
