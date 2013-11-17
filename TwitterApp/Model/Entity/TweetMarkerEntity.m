//
//  TweetMarkerEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 31/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetMarkerEntity.h"
#import "AFTwitterClient.h"

@implementation TweetMarkerEntity

+ (NSOperation*)requestTweetMarkersWithUsername:(NSString*)username completionHandler:(void (^)(TweetMarkerEntity* tweetMarker, NSError* error))block {
    
    NSParameterAssert(username.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"api_key": @"TW-28DBB7FD1B97", @"username": username, @"collection": @"timeline"};
    
    NSMutableURLRequest *request = [apiClient oAuthEchoRequestWithMethod:@"GET" URLString:@"https://api.tweetmarker.net/v2/lastread" parameters:params];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        TweetMarkerEntity* tweetMarker = [[TweetMarkerEntity alloc] initWithDictionary:JSON[@"timeline"]];
        
        block(tweetMarker, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient.operationQueue addOperation:operation];
    
    return operation;
}

@end
