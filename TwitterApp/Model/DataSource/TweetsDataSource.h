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

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadNewTweets:(NSArray*)tweets cached:(BOOL)cached;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadNewTweetsWithError:(NSError*)error;

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadOldTweets:(NSArray*)tweets;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadOldTweetsWithError:(NSError*)error;

- (void)tweetDataSource:(TweetsDataSource*)dataSource didFillGap:(GapTweetEntity*)gap withTweets:(NSArray*)tweets;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToFillGap:(GapTweetEntity*)gap error:(NSError*)error;

- (void)tweetDataSource:(TweetsDataSource*)dataSource didDeleteTweets:(NSArray*)tweet;
- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToDeleteTweetWithError:(NSError*)error;

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock;

@end

@interface TweetsDataSource : NSObject

- (NSArray*)tweets;

- (instancetype)initWithPersistenceIdentifier:(NSString*)persistenceIdentifier;

- (BOOL)loadNewTweets;
- (void)loadOldTweets;
- (void)loadTweetsForGap:(GapTweetEntity*)gap;
- (void)deleteTweet:(TweetEntity*)tweet;

@property(nonatomic, weak) id <TweetDataSourceDelegate> delegate;
@property(nonatomic, readonly) BOOL isReady;

@end
