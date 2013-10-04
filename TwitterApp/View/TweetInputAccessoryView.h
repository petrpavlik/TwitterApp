//
//  TweetInputAccessoryView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetInputAccessoryView;

@protocol TweetInputAccessoryViewDelegate <NSObject>

- (void)tweetInputAccessoryViewDidRequestMediaQuery:(TweetInputAccessoryView*)view;
- (void)tweetInputAccessoryViewDidEnableLocation:(TweetInputAccessoryView*)view;
- (void)tweetInputAccessoryViewDidDisableLocation:(TweetInputAccessoryView*)view;
- (void)tweetInputAccessoryViewDidRequestPlaceQuery:(TweetInputAccessoryView*)view;
- (void)tweetInputAccessoryView:(TweetInputAccessoryView*)view didSelectQuickAccessString:(NSString*)string;

@end

@interface TweetInputAccessoryView : UIView

- (void)disableLocation;
- (void)enableLocation;
- (void)displayLocationPlace:(NSString*)placeName;
- (void)displaySelectedImage:(UIImage*)image;

- (void)setBackgroundOpaque:(BOOL)isOpaque animated:(BOOL)isAnimated;

- (void)displayMentions:(NSString*)mentions; //pass nil to hide it again

@property(nonatomic, weak) id <TweetInputAccessoryViewDelegate> delegate;
@property(nonatomic, readonly) BOOL locationEnabled;

@end
