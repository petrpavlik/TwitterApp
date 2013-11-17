//
//  TweetMarkerEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 31/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetMarkerEntity.h"
#import "AFTwitterClient.h"
#import <AFHTTPRequestOperation.h>

#define kAPIKey @"TW-28DBB7FD1B97"

@implementation TweetMarkerEntity

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"Id"]) {
        
        self.tweetId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

#pragma mark -

+ (NSOperation*)requestTweetMarkerWithUsername:(NSString*)username completionHandler:(void (^)(TweetMarkerEntity* tweetMarker, NSError* error))block {
    
    NSParameterAssert(username.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"api_key": kAPIKey, @"username": username, @"collection": @"timeline"};
    
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

+ (NSOperation*)notifyTweetMarkerUpdateWithTweetId:(NSString*)tweetId username:(NSString*)username completionHandler:(void (^)(NSError* error))block {
    
    NSParameterAssert(tweetId.length);
    NSParameterAssert(username.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"timeline": @{@"id": tweetId}};
    
    AFHTTPRequestSerializer* originalSerializer = apiClient.requestSerializer;
    apiClient.requestSerializer = [AFJSONRequestSerializer new];
    NSMutableURLRequest *request = [apiClient oAuthEchoRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"https://api.tweetmarker.net/v2/lastread?username=%@&api_key=%@", username, kAPIKey] parameters:params];
    apiClient.requestSerializer = originalSerializer;
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(error);
    }];
    
    NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
    
    [apiClient.operationQueue addOperation:operation];
    
    __weak AFHTTPRequestOperation* weakOperation = operation;
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        [weakOperation cancel];
    }];
    
    return operation;
}

@end
