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
    else if ([key isEqualToString:@"CreatedAt"]) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        self.createdAt = [df dateFromString:value];
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

@end
