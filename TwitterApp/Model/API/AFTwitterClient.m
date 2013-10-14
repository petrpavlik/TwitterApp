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

#pragma mark - utilities

- (NSError*)sanitizedError:(NSError*)error {
    
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
        
        if (code && message) {
            return [NSError errorWithDomain:domain code:[code integerValue] userInfo:@{NSLocalizedDescriptionKey: message}];
        }
    }
    
    return error;
}

#pragma mark -

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
    
    SLRequestMethod requestMethod = SLRequestMethodGET;
    
    if ([method isEqualToString:@"GET"]) {
        requestMethod = SLRequestMethodGET;
    }
    else if ([method isEqualToString:@"POST"]) {
        requestMethod = SLRequestMethodPOST;
    }
    else if ([method isEqualToString:@"DELETE"]) {
        requestMethod = SLRequestMethodDELETE;
    }
    else {
        
        [NSException raise:@"Unknown request method" format:nil];
        return nil;
    }
    
    if (requestMethod == SLRequestMethodGET) {
        parameters = nil; //already contained in URL
    }
    
    SLRequest* slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:afRequest.URL parameters:parameters];
    slRequest.account = self.account;
    
    NSURLRequest* signedRequest = slRequest.preparedURLRequest;
    
    [afRequest setValue:signedRequest.allHTTPHeaderFields[@"Authorization"] forHTTPHeaderField:@"Authorization"];
    afRequest.HTTPBody = signedRequest.HTTPBody;
    
    return afRequest;
    //return signedRequest;
}

- (NSMutableURLRequest *)signedMultipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                                            multipartData:(NSArray*)multipartData
{
    
    NSMutableURLRequest* afRequest = [self multipartFormRequestWithMethod:method path:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSDictionary* data in multipartData) {
            
            [formData appendPartWithFileData:data[@"data"] name:data[@"name"] fileName:data[@"filename"] mimeType:data[@"mime"]];
        }
    }];
    
    SLRequestMethod requestMethod = SLRequestMethodGET;
    
    if ([method isEqualToString:@"GET"]) {
        requestMethod = SLRequestMethodGET;
    }
    else if ([method isEqualToString:@"POST"]) {
        requestMethod = SLRequestMethodPOST;
    }
    else if ([method isEqualToString:@"DELETE"]) {
        requestMethod = SLRequestMethodDELETE;
    }
    else {
        
        [NSException raise:@"Unknown request method" format:nil];
        return nil;
    }
    
    if (requestMethod == SLRequestMethodGET) {
        parameters = nil; //already contained in URL
    }
    
    SLRequest* slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:afRequest.URL parameters:parameters];
    slRequest.account = self.account;
    
    for (NSDictionary* data in multipartData) {
        
        [slRequest addMultipartData:data[@"data"] withName:data[@"name"] type:data[@"mime"] filename:data[@"filename"]];
    }
    
    NSURLRequest* signedRequest = slRequest.preparedURLRequest;
    NSMutableDictionary* headerFields = [signedRequest.allHTTPHeaderFields mutableCopy];
    headerFields[@"User-Agent"] = afRequest.allHTTPHeaderFields[@"User-Agent"];
    
    NSMutableURLRequest* mutableSignedRequest = [signedRequest mutableCopy];
    mutableSignedRequest.allHTTPHeaderFields = headerFields;
    
    return mutableSignedRequest;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)operation.response;
        if (httpResponse) {
            
            int responseStatusCode = [httpResponse statusCode];
            if (responseStatusCode == 400 || responseStatusCode == 401) {
                
                [[[UIAlertView alloc] initWithTitle:@"Unauthorized Access" message:@"Please make sure that your Twitter account has a password filled in. You can find out by opening the Settings app and navigating to section Twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
        
        NSError* sanitizedError = [self sanitizedError:error];
        failure(operation, sanitizedError);
    }];
}


@end
