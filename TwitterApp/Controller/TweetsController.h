//
//  TweetsController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseTweetsController.h"
#import "TweetsDataSource.h"

@interface TweetsController : BaseTweetsController <TweetDataSourceDelegate>

- (NSString*)tweetsPersistenceIdentifier;

@end
