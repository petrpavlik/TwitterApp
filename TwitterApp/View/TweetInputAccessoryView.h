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

@end

@interface TweetInputAccessoryView : UIView

- (void)displayLocationPlace:(NSString*)placeName;

@property(nonatomic, weak) id <TweetInputAccessoryViewDelegate> delegate;
@property(nonatomic, strong) UIButton* locationButton;
@property(nonatomic, strong) UIButton* placeButton;

@end
