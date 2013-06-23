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
#import <UIImage+TwitterApp.h>

@interface TweetInputAccessoryView ()

@property(nonatomic, strong) NSArray* locationDisabledConstraints;
@property(nonatomic, strong) NSArray* locationEnabledCOnstraints;

@property(nonatomic, strong) UIButton* locationButton;
@property(nonatomic, strong) UIButton* mediaButton;
@property(nonatomic, strong) UIButton* placeButton;

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
    
    //self.backgroundColor = [UIColor redColor];
    
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = skin.linkColor;
    }
    
    _locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage* locationImage = [[UIImage imageNamed:@"Btn-Location"] imageResizedToSize:CGSizeMake(30, 17)];
    [_locationButton setImage:locationImage forState:UIControlStateNormal];
    //_locationButton.imageView.contentMode = UIViewContentModeCenter;
    _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_locationButton];
    
    _placeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _placeButton.titleLabel.font = [skin fontOfSize:15];
    [_placeButton setTitle:@"San Francisco" forState:UIControlStateNormal];
    _placeButton.translatesAutoresizingMaskIntoConstraints = NO;
    _placeButton.hidden = YES;
    _placeButton.alpha = 0;
    [_placeButton addTarget:self action:@selector(placeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_placeButton];
    
    _mediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_mediaButton setImage:[UIImage imageNamed:@"Btn-Add-Image"] forState:UIControlStateNormal];
    _mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_mediaButton addTarget:self action:@selector(mediaButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_mediaButton];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    self.locationEnabledCOnstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[_locationButton(>=44)]-4-[_placeButton]-[_mediaButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _mediaButton, _placeButton)];
    
    self.locationDisabledConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-3-[_locationButton(>=44)]-[_mediaButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _mediaButton, _placeButton)];
    self.locationDisabledConstraints = [self.locationDisabledConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_locationButton]-4-[_placeButton]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_locationButton, _placeButton)]];
    
    [superviewConstraints addObjectsFromArray:self.locationDisabledConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0]];
    
    
    [self addConstraints:superviewConstraints];
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

#pragma mark -

- (void)displayLocationPlace:(NSString*)placeName {
    
    if (!placeName.length) {
        return;
    }
    
    [self.placeButton setTitle:placeName forState:UIControlStateNormal];
    
    [self removeConstraints:self.locationDisabledConstraints];
    [self addConstraints:self.locationEnabledCOnstraints];
    self.placeButton.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 1;
    }];
}

- (void)disableLocation {
    
    self.locationButton.selected = NO;
    
    [self removeConstraints:self.locationEnabledCOnstraints];
    [self addConstraints:self.locationDisabledConstraints];
    self.placeButton.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self layoutIfNeeded];
        self.placeButton.alpha = 0;
    }];
    
    [self.delegate tweetInputAccessoryViewDidDisableLocation:self];
}

- (BOOL)locationEnabled {
    return self.locationButton.selected;
}

- (void)displaySelectedImae:(UIImage*)image {
    NSParameterAssert(image);
    
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
    scaledImage = [scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [self.mediaButton setImage:scaledImage forState:UIControlStateNormal];
}

@end
