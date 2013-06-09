//
//  TweetEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFTwitterClient.h"
#import "TweetEntity.h"

@implementation TweetEntity

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"User"]) {
    
        self.user = [[UserEntity alloc] initWithDictionary:value];
    }
    else if ([key isEqualToString:@"RetweetedStatus"]) {
        
        self.retweetedStatus = [[TweetEntity alloc] initWithDictionary:value];
    }
    else if ([key isEqualToString:@"CreatedAt"] && ![value isKindOfClass:[NSDate class]]) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        self.createdAt = [df dateFromString:value];
    }
    else if ([key isEqualToString:@"InReplyToStatusIdStr"]) {
        
        self.inReplyToStatusId = value;
    }
    else if ([key isEqualToString:@"InReplyToStatusId"]) {
        //do nothing
    }
    else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"IdStr"]) {
        
        self.tweetId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

#pragma mark -

+ (NSOperation*)requestHomeTimelineWithMaxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block  {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* mutableParams = [@{@"count": @"50"} mutableCopy];
    
    if (maxId) {
        mutableParams[@"max_id"] = maxId;
    }
    
    if (sinceId) {
        mutableParams[@"since_id"] = sinceId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"statuses/home_timeline.json" parameters:mutableParams];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestRetweetWithCompletionBlock:(void (^)(TweetEntity* updatedTweet, NSError* error))block {
    
    NSParameterAssert(self.tweetId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];

    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:[NSString stringWithFormat: @"statuses/retweet/%@.json", self.tweetId] parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
       TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestStatusUpdateWithText:(NSString*)text asReplyToTweet:(NSString*)tweetId completionBlock:(void (^)(TweetEntity* tweet, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    params[@"status"] = text;
    
    if (tweetId) {
        params[@"in_reply_to_status_id"] = tweetId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"statuses/update.json" parameters:params];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestRetweetsOfTweet:(NSString*)tweetId completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"statuses/retweets/%@.json", tweetId] parameters:@{@"count": @"100"}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;

}

+ (NSOperation*)requestSearchWithQuery:(NSString*)query maxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    NSParameterAssert(query);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* mutableParams = [@{@"q": query, @"count": @"50"} mutableCopy];
    
    if (maxId) {
        mutableParams[@"max_id"] = maxId;
    }
    
    if (sinceId) {
        mutableParams[@"since_id"] = sinceId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"search/tweets.json" parameters:mutableParams];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        JSON = JSON[@"statuses"];
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestUserTimelineWithScreenName:(NSString*)screenName maxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    NSParameterAssert(screenName);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* mutableParams = [@{@"screen_name": screenName, @"count": @"50"} mutableCopy];
    
    if (maxId) {
        mutableParams[@"max_id"] = maxId;
    }
    
    if (sinceId) {
        mutableParams[@"since_id"] = sinceId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"statuses/user_timeline.json" parameters:mutableParams];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestSearchRepliesWithTweetId:(NSString*)tweetId screenName:(NSString*)screenName completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    NSParameterAssert(tweetId);
    NSParameterAssert(screenName);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* parameters = @{@"q": [NSString stringWithFormat:@"to:%@", screenName], @"count": @"100", @"result_type": @"recent", @"since_id": tweetId};
    
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"search/tweets.json" parameters:parameters];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        JSON = JSON[@"statuses"];
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* reply = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            if ([reply.inReplyToStatusId isEqualToString:tweetId]) {
                [tweets addObject:reply];
            }
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestTweetWithId:(NSString*)tweetId completionBlock:(void (^)(TweetEntity* tweet, NSError* error))block {
    
    NSParameterAssert(tweetId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* parameters = @{@"id": tweetId};
    
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"statuses/show.json" parameters:parameters];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestRetweetsOfTweetWithId:(NSString*)tweetId completionBlock:(void (^)(NSArray* retweets, NSError* error))block {
    
    NSParameterAssert(tweetId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:[NSString stringWithFormat:@"statuses/retweets/%@.json", tweetId] parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

#pragma mark -

+ (void)testStream {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"https://stream.twitter.com/1.1/statuses/filter.json" parameters:@{@"follow": @"14461738,145816941"}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@", JSON);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
}

+ (void)testDirectMessages {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"https://api.twitter.com/1.1/direct_messages.json" parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@", JSON);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
}

@end
