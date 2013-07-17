//
//  TweetController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/26/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetEntity.h"
#import <UIKit/UIKit.h>

@interface TweetController : UIViewController

+ (TweetController*)presentAsReplyToTweet:(TweetEntity*)tweet inViewController:(UIViewController*)viewController;
+ (TweetController*)presentInViewController:(UIViewController*)viewController;
+ (TweetController*)presentInViewController:(UIViewController*)viewController prefilledText:(NSString*)text;

@property(nonatomic, strong) UIImage* backgroundImage;

@end
