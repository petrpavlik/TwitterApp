//
//  TweetInputAccessoryView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "TweetInputAccessoryView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+TwitterApp.h"

@interface TweetInputAccessoryView ()

@property(nonatomic, strong) NSArray* locationDisabledConstraints;
@property(nonatomic, strong) NSArray* locationEnabledCOnstraints;

@property(nonatomic, strong) UIButton* locationButton;
@property(nonatomic, strong) UIButton* mediaButton;
@property(nonatomic, strong) UIButton* placeButton;
@property(nonatomic, strong) UIButton* hashtagButton;
@property(nonatomic, strong) UIButton* mentionButton;

@property(nonatomic, strong) UIScrollView* baseScrollView;
@property(nonatomic, strong) UIView* defaultActionsPlaceholderView;
@property(nonatomic, strong) UIScrollView* mentionHintsScrollView;

@end

@implementation TweetInputAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    AbstractSkin* skin = [(AppDelegate*)[UIApplication sharedApplication].delegate skin];
    
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = skin.linkColor;
    }
    
    _baseScrollView = [UIScrollView new];
    _baseScrollView.frame = CGRectMake(0, 0, 320, 44);
    _baseScrollView.scrollEnabled = NO;
    [self addSubview:_baseScrollView];
    
    _defaultActionsPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [_baseScrollView addSubview:_defaultActionsPlaceholderView];
    
    _mentionHintsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(320, 0, 320, 44)];
    [_baseScrollView addSubview:_mentionHintsScrollView];
    
    [self constructDefaultActionsPlaceholderViewInView:_defaultActionsPlaceholderView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _baseScrollView.frame = self.bounds;
    _defaultActionsPlaceholderView.frame = self.bounds;
    
    CGRect hintsScrollViewFrame = self.bounds;
    hintsScrollViewFrame.origin.x += self.bounds.size.width;
    _mentionHintsScrollView.frame = hintsScrollViewFrame;
    
    _baseScrollView.contentSize = CGSizeMake(self.bounds.size.width*2, self.bounds.size.height);
    
    if (_mentionHintsScrollView.subviews.count) {
        [self.baseScrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:YES];
    }
    else {
        [self.baseScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)locationButtonPressed {
    
    self.locationButton.selected = !self.locationButton.selected;
    
    if (self.locationButton.selected) {
        
        [self.delegate tweetInputAccessoryViewDidEnableLocation:self];
    }
    else {
        [self disableLocation];
    }
}

- (void)mediaButtonPressed {
    
    [self.delegate tweetInputAccessoryViewDidRequestMediaQuery:self];
}

- (void)placeButtonPressed {
    
    [self.delegate tweetInputAccessoryViewDidRequestPlaceQuery:self];
}

- (void)hashtagSelected {
    [self.delegate tweetInputAccessoryView:self didSelectQuickAccessString:@"#"];
}

- (void)mentionSelected {
    [self.delegate tweetInputAccessoryView:self didSelectQuickAccessString:@"@"];
}

#pragma mark -

- (void)displayLocationPlace:(NSString*)placeName {
    
    if (!placeName.length) {
        return;
    }
    
    [self.placeButton setTitle:placeName forState:UIControlStateNormal];
    
    [_defaultActionsPlaceholderView removeConstraints:self.locationDisabledConstraints];
    [_defaultActionsPlaceholderView addConstraints:self.locationEnabledCOnstraints];
    self.placeButton.hidden = NO;
    
    /*[UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:0 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 1;
        
    } completion:NULL];*/
    
    /*[UIView animateWithDuration:0.25 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 1;
    }];*/
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 1;
        
    } completion:NULL];
}

- (void)disableLocation {
    
    self.locationButton.selected = NO;
    
    [_defaultActionsPlaceholderView removeConstraints:self.locationEnabledCOnstraints];
    [_defaultActionsPlaceholderView addConstraints:self.locationDisabledConstraints];
    self.placeButton.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 0;
    }];
    
    [self.delegate tweetInputAccessoryViewDidDisableLocation:self];
}

- (void)enableLocation {
    [self locationButtonPressed];
}

- (BOOL)locationEnabled {
    return self.locationButton.selected;
}

- (void)displaySelectedImage:(UIImage*)image {
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.mediaButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self assignImageToMediaButton:image];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.mediaButton.alpha = 1;
        }];
    }];
}

- (void)assignImageToMediaButton:(UIImage*)image {
    
    if (!image) {
        [_mediaButton setImage:[UIImage imageNamed:@"Btn-Image"] forState:UIControlStateNormal];
        return;
    }
    
    CGSize previewImageSize = CGSizeMake(34, 34);
    CGRect imageDrawRect;
    
    if (image.size.width >= image.size.height) {
        
        CGSize imageScaledSize = CGSizeMake((int)(image.size.width*(previewImageSize.height/image.size.height)), previewImageSize.height);
        imageDrawRect = CGRectMake((previewImageSize.width-imageScaledSize.width)/2.0, 0, imageScaledSize.width, imageScaledSize.height);
    }
    else {
        
        CGSize imageScaledSize = CGSizeMake(previewImageSize.width, (int)(image.size.height*(previewImageSize.width/image.size.width)));
        imageDrawRect = CGRectMake(0, (previewImageSize.height-imageScaledSize.height)/2.0, imageScaledSize.width, imageScaledSize.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(previewImageSize, NO, 0);
    [image drawInRect:imageDrawRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scaledImage = [scaledImage imageWithRoundCornersWithRadius:3];
    
    if ([scaledImage respondsToSelector:@selector(imageWithRenderingMode:)]) {
        scaledImage = [scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [self.mediaButton setImage:scaledImage forState:UIControlStateNormal];
}

- (void)setBackgroundOpaque:(BOOL)isOpaque animated:(BOOL)isAnimated {
    
    #define kAlphaWhenOpaque 0.8
    
    if (!isAnimated) {
        
        if (isOpaque) {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:kAlphaWhenOpaque];
        }
        else {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
        }
    }
    else {
        
        if (isOpaque) {
            [UIView animateWithDuration:0.35 animations:^{
                self.backgroundColor = [UIColor colorWithWhite:1 alpha:kAlphaWhenOpaque];
            }];
        }
        else {
            [UIView animateWithDuration:0.35 animations:^{
                self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
            }];
        }
    }
}

- (void)constructDefaultActionsPlaceholderViewInView:(UIView*)view {
    
    AbstractSkin* skin = [(AppDelegate*)[UIApplication sharedApplication].delegate skin];
    
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage* locationImage = [[UIImage imageNamed:@"Btn-Location"] imageResizedToSize:CGSizeMake(30, 17)];
    [_locationButton setImage:locationImage forState:UIControlStateNormal];
    //_locationButton.imageView.contentMode = UIViewContentModeCenter;
    _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_locationButton];
    
    _placeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _placeButton.titleLabel.font = [skin fontOfSize:15];
    [_placeButton setTitle:@"San Francisco" forState:UIControlStateNormal];
    _placeButton.translatesAutoresizingMaskIntoConstraints = NO;
    _placeButton.hidden = YES;
    _placeButton.alpha = 0;
    _placeButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation; //TODO: switch to TextKit after dropping iOS 6;
    [_placeButton addTarget:self action:@selector(placeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_placeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [view addSubview:_placeButton];
    
    _mediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_mediaButton setImage:[UIImage imageNamed:@"Btn-Image"] forState:UIControlStateNormal];
    _mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_mediaButton addTarget:self action:@selector(mediaButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_mediaButton];
    
    _hashtagButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _hashtagButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_hashtagButton setTitle:@"#" forState:UIControlStateNormal];
    _hashtagButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    [_hashtagButton addTarget:self action:@selector(hashtagSelected) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_hashtagButton];
    
    _mentionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _mentionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_mentionButton setTitle:@"@" forState:UIControlStateNormal];
    _mentionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    [_mentionButton addTarget:self action:@selector(mentionSelected) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_mentionButton];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    self.locationEnabledCOnstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[_locationButton(>=44)]-4-[_placeButton]-[_mediaButton(>=44)]->=8-[_hashtagButton(>=44)]-4-[_mentionButton(>=44)]-8-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _mediaButton, _placeButton, _hashtagButton, _mentionButton)];
    
    self.locationDisabledConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[_locationButton(>=44)]-[_mediaButton(>=44)]->=8-[_hashtagButton(>=44)]-4-[_mentionButton(>=44)]-8-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _mediaButton, _placeButton, _hashtagButton, _mentionButton)];
    self.locationDisabledConstraints = [self.locationDisabledConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_locationButton]-4-[_placeButton]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _placeButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hashtagButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_hashtagButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_mentionButton(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mentionButton)]];
    
    [superviewConstraints addObjectsFromArray:self.locationDisabledConstraints];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    
    [view addConstraints:superviewConstraints];
}

- (void)displayMentions:(NSArray *)mentions {
    
    if (mentions.count) {
        
        [self setMentionHints:mentions];
        [self.baseScrollView setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:YES];
    }
    else {
        [self.baseScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)setMentionHints:(NSArray*)mentionHints {
    
    while (_mentionHintsScrollView.subviews.count) {
        [_mentionHintsScrollView.subviews[0] removeFromSuperview];
    }
    
    CGFloat offset = 10;
    
    for (UserEntity* user in mentionHints) {
        
        UIButton* hintButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hintButton setTitle:[NSString stringWithFormat:@"@%@", user.screenName] forState:UIControlStateNormal];
        
        CGSize intrinsicContentSize = hintButton.intrinsicContentSize;
        hintButton.frame = CGRectMake(offset, (_mentionHintsScrollView.bounds.size.height-intrinsicContentSize.height)/2, intrinsicContentSize.width, intrinsicContentSize.height);
        [hintButton addTarget:self action:@selector(mentionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_mentionHintsScrollView addSubview:hintButton];
        
        offset += intrinsicContentSize.width + 10;
    }
    
    _mentionHintsScrollView.contentSize = CGSizeMake(offset+10, _mentionHintsScrollView.bounds.size.height);
}

- (void)mentionSelected:(UIButton*)sender {
    
    [self.delegate tweetInputAccessoryView:self didSelectMention:[sender titleForState:UIControlStateNormal]];
}

@end
