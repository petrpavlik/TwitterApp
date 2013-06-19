//
//  TweetEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"
#import <Foundation/Foundation.h>
#import "UserEntity.h"

@interface TweetEntity : BaseEntity

@property(nonatomic, strong) NSDate* createdAt;
@property(nonatomic, strong) NSNumber* favoriteCount;
@property(nonatomic, strong) NSDictionary* entities;
@property(nonatomic, strong) NSNumber* favorited;
@property(nonatomic, strong) NSNumber* filterLevel;
@property(nonatomic, strong) NSString* tweetId;
@property(nonatomic, strong) NSString* inReplyToStatusId;
@property(nonatomic, strong) NSString* lang;
@property(nonatomic, strong) NSDictionary* place;
@property(nonatomic, strong) NSNumber* possiblySensitive;
@property(nonatomic, strong) NSDictionary* scopes;
@property(nonatomic, strong) NSNumber* retweetCount;
@property(nonatomic, strong) NSNumber* retweeted;
@property(nonatomic, strong) TweetEntity* retweetedStatus;
@property(nonatomic, strong) NSString* source;
@property(nonatomic, strong) NSString* text;
@property(nonatomic, strong) NSNumber* truncated;
@property(nonatomic, strong) UserEntity* user;

+ (NSOperation*)requestHomeTimelineWithMaxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block;

+ (NSOperation*)requestUserTimelineWithScreenName:(NSString*)screenName maxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block;

- (NSOperation*)requestRetweetWithCompletionBlock:(void (^)(TweetEntity* updatedTweet, NSError* error))block;

+ (NSOperation*)requestStatusUpdateWithText:(NSString*)text asReplyToTweet:(NSString*)tweetId completionBlock:(void (^)(TweetEntity* tweet, NSError* error))block;

+ (NSOperation*)requestRetweetsOfTweet:(NSString*)tweetId completionBlock:(void (^)(NSArray* tweets, NSError* error))block;

+ (NSOperation*)requestSearchWithQuery:(NSString*)query maxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block;

+ (NSOperation*)requestSearchRepliesWithTweetId:(NSString*)tweetId screenName:(NSString*)screenName completionBlock:(void (^)(NSArray* tweets, NSError* error))block;

+ (NSOperation*)requestTweetWithId:(NSString*)tweetId completionBlock:(void (^)(TweetEntity* tweet, NSError* error))block;

+ (NSOperation*)requestRetweetsOfTweetWithId:(NSString*)tweetId completionBlock:(void (^)(NSArray* retweets, NSError* error))block;

+ (NSOperation*)requestDeletionOfTweetWithId:(NSString*)tweetId completionBlock:(void (^)(NSError* error))block;

+ (void)testStream;
+ (void)testDirectMessages;

@end
