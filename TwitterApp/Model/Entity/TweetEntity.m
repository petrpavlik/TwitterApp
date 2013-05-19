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

+ (NSOperation*)requestHomeTimelineWithCompletionBlock:(void (^)(NSArray* tweets, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"statuses/home_timeline.json" parameters:nil];
    
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
