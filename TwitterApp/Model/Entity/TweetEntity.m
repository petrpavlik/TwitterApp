//
//  TweetEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
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
        
        if ([value isKindOfClass:[NSString class]]) {
            self.inReplyToStatusId = value;
        }
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
    
    NSMutableDictionary* mutableParams = [@{@"count": @"200"} mutableCopy];
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(tweets, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestMentionsTimelineWithMaxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* mutableParams = [@{@"count": @"200"} mutableCopy];
    
    if (maxId) {
        mutableParams[@"max_id"] = maxId;
    }
    
    if (sinceId) {
        mutableParams[@"since_id"] = sinceId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"statuses/mentions_timeline.json" parameters:mutableParams];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(tweets, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestFavoritesTimelineWithMaxId:(NSString*)maxId sinceId:(NSString*)sinceId completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* mutableParams = [@{@"count": @"200"} mutableCopy];
    
    if (maxId) {
        mutableParams[@"max_id"] = maxId;
    }
    
    if (sinceId) {
        mutableParams[@"since_id"] = sinceId;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"favorites/list.json" parameters:mutableParams];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            [tweets addObject:tweet];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(tweets, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
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

- (NSOperation*)requestFavoriteWithCompletionBlock:(void (^)(TweetEntity* updatedTweet, NSError* error))block {
    
    NSParameterAssert(self.tweetId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"favorites/create.json" parameters:@{@"id": self.tweetId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestUnfavoriteWithCompletionBlock:(void (^)(TweetEntity* updatedTweet, NSError* error))block {
    
    NSParameterAssert(self.tweetId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"favorites/destroy.json" parameters:@{@"id": self.tweetId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestStatusUpdateWithText:(NSString*)text asReplyToTweet:(NSString*)tweetId location:(CLLocation*)location placeId:(NSString*)placeId media:(NSArray*)media completionBlock:(void (^)(TweetEntity* tweet, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    params[@"status"] = text;
    
    if (tweetId) {
        params[@"in_reply_to_status_id"] = tweetId;
    }
    
    if (placeId) {
        params[@"place_id"] = placeId;
    }
    
    if (location) {
        params[@"lat"] = @(location.coordinate.latitude);
        params[@"long"] = @(location.coordinate.longitude);
    }
    
    NSMutableURLRequest *request = nil;
    
    if (media.count) {
    
        /*request = [apiClient signedMultipartFormRequestWithMethod:@"POST" path:@"statuses/update_with_media.json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for (UIImage* image in media) {
                
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8) name:@"media[]" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
            }
        }];*/
        
        request = [apiClient signedMultipartFormRequestWithMethod:@"POST" path:@"statuses/update_with_media.json" parameters:params multipartData:@[@{@"data": UIImageJPEGRepresentation(media[0], 0.8), @"name": @"media[]", @"filename": @"image.jpeg", @"mime": @"image/jpeg"}]];
    }
    else {
        
        request = [apiClient signedRequestWithMethod:@"POST" path:@"statuses/update.json" parameters:params];
    }
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:JSON];
        block(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString* recoverySuggestion = error.localizedRecoverySuggestion;
        NSError* jsonError = nil;
        NSDictionary* twitterErrorDictionary = nil;
        
        if (recoverySuggestion) {
            twitterErrorDictionary = [NSJSONSerialization JSONObjectWithData:[recoverySuggestion dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        }
        
        if (twitterErrorDictionary && !jsonError) {
            
            NSBundle *bundle = [NSBundle mainBundle];
            NSDictionary *info = [bundle infoDictionary];
            NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
            
            NSString* domain = [prodName stringByAppendingString:@".TwitterAPI"];
            
            NSNumber* code = twitterErrorDictionary[@"errors"][0][@"code"];
            NSString* message = twitterErrorDictionary[@"errors"][0][@"message"];
            
            block(nil, [NSError errorWithDomain:domain code:[code integerValue] userInfo:@{NSLocalizedDescriptionKey: message}]);
        }
        else {
            block(nil, error);
        }
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        
        block(nil, [NSError errorWithDomain:prodName code:0 userInfo:@{NSLocalizedDescriptionKey: @"Background task for this operation expired before the operation was completed."}]);
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
                
                if ([[reply.text substringToIndex:1] isEqualToString:@"@"]) {
                    [tweets addObject:reply];
                }
            }
        }
        
        block(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestSearchOlderRelatedTweetsWithTweet:(TweetEntity*)tweet screenName:(NSString*)screenName completionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    NSParameterAssert(tweet);
    NSParameterAssert(screenName);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* parameters = @{@"q": [NSString stringWithFormat:@"from:%@ OR to:%@", screenName, screenName], @"count": @"100", @"result_type": @"recent", @"max_id": tweet.tweetId};
    
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"search/tweets.json" parameters:parameters];
    
    TweetEntity* originalTweet = tweet;
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        JSON = JSON[@"statuses"];
        
        NSMutableArray* tweets = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* tweetDictionary in JSON) {
            
            TweetEntity* tweet = [[TweetEntity alloc] initWithDictionary:tweetDictionary];
            
            if (tweets.count) {
                
                if ([tweets.lastObject inReplyToStatusId]) {
                    
                    if ([[tweets.lastObject inReplyToStatusId] isEqualToString:tweet.tweetId]) {
                        [tweets addObject:tweet];
                    }
                }
                else {
                    break;
                }
            }
            else {
                
                if ([originalTweet.inReplyToStatusId isEqualToString:tweet.tweetId]) {
                    [tweets addObject:tweet];
                }
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

+ (NSOperation*)requestDeletionOfTweetWithId:(NSString*)tweetId completionBlock:(void (^)(NSError* error))block {
    
    NSParameterAssert(tweetId.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"statuses/destroy/%@.json", tweetId] parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

#pragma mark -

+ (void)testStream {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"https://stream.twitter.com/1.1/statuses/filter.json" parameters:@{@" follow": @"14461738,145816941"}];
    
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
