//
//  TweetsDataSource.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "GapTweetEntity.h"
#import <Foundation/Foundation.h>

@class TweetsDataSource;

@protocol TweetDataSourceDelegate <NSObject>

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadNewTweets:(NSArray*)tweets;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadNewTweetsWithError:(NSError*)error;

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadOldTweets:(NSArray*)tweets;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadOldTweetsWithError:(NSError*)error;

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock;

@end

@interface TweetsDataSource : NSObject

- (NSArray*)tweets;

- (void)loadNewTweets;
- (void)loadOldTweets;
- (void)loadTweetsForGap:(GapTweetEntity*)gap;
- (void)deleteTweet:(TweetEntity*)tweet;

@property(nonatomic, weak) id <TweetDataSourceDelegate> delegate;

@end
