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
@property(nonatomic, strong) NSString* inReplyToScreenName;
@property(nonatomic, strong) NSString* inReplyToStatusId;
@property(nonatomic, strong) NSString* inReplyToUserId;
@property(nonatomic, strong) NSString* lang;
@property(nonatomic, strong) NSNumber* possiblySensitive;
@property(nonatomic, strong) NSDictionary* scopes;
@property(nonatomic, strong) NSNumber* retweetCount;
@property(nonatomic, strong) NSNumber* retweeted;
@property(nonatomic, strong) NSString* source;
@property(nonatomic, strong) NSString* text;
@property(nonatomic, strong) NSNumber* truncated;
@property(nonatomic, strong) UserEntity* user;

+ (NSOperation*)requestHomeTimelineWithCompletionBlock:(void (^)(NSArray* tweets, NSError* error))block;

@end
