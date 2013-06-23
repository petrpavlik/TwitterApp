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

@end

@interface TweetInputAccessoryView : UIView

- (void)disableLocation;
- (void)displayLocationPlace:(NSString*)placeName;
- (void)displaySelectedImae:(UIImage*)image;

@property(nonatomic, weak) id <TweetInputAccessoryViewDelegate> delegate;
@property(nonatomic, readonly) BOOL locationEnabled;

@end
