//
//  TweetDetailController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseTweetsController.h"

@class TweetEntity;

@interface TweetDetailController : BaseTweetsController

@property(nonatomic, strong) TweetEntity* tweet;

@end
