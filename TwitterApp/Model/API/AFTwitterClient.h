//
//  AFTwitterClient.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <AFHTTPRequestOperationManager.h>

@interface AFTwitterClient : AFHTTPRequestOperationManager

@property(nonatomic, strong) ACAccount* account;

+ (AFTwitterClient*)sharedClient;

- (NSMutableURLRequest *)signedMultipartFormRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters multipartData:(NSArray*)multipartData;

- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters;

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation*)operation __deprecated;
- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters __deprecated;

@end
