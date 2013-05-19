//
//  AFTwitterClient.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFTwitterClient.h"
#import "AFTwitterJSONRequestOperation.h"
#import <Social/Social.h>

@implementation AFTwitterClient

static NSString * const kAFTwitterAPIBaseURLString = @"https://api.twitter.com/1.1/";

+ (AFTwitterClient*)sharedClient {
    static AFTwitterClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFTwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kAFTwitterAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFTwitterJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    /*[self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RPNetworkDidBecomeReachable object:nil];
        }
        else if (status == AFNetworkReachabilityStatusNotReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RPNetworkDidBecomeUnreachable object:nil];
        }
    }];*/
    
    return self;
}

- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    
    NSParameterAssert(self.account);
    
    NSMutableURLRequest* afRequest = [self requestWithMethod:method path:path parameters:parameters];
    
    SLRequest* slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:afRequest.URL parameters:parameters];
    slRequest.account = self.account;
    
    NSURLRequest* signedRequest = slRequest.preparedURLRequest;
    
    [afRequest setValue:signedRequest.allHTTPHeaderFields[@"Authorization"] forHTTPHeaderField:@"Authorization"];
    
    //return afRequest;
    return signedRequest;
}


@end
