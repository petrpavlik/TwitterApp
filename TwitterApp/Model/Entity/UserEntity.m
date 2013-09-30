//
//  UserEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
#import "AFTwitterClient.h"
#import "NSString+TwitterApp.h"
#import "UserEntity.h"
#import "TweetEntity.h"

static UserEntity* currentUser;

@implementation UserEntity

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"IdStr"]) {
        
        self.userId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"Description"]) {
        self.userDescription = value;
    }
    else if ([key isEqualToString:@"Status"]) {
        self.status = [[TweetEntity alloc] initWithDictionary:value];
    }
    else {
        [super setValue:value forKey:key];
    }
}

#pragma mark -

- (NSString*)expandedUserDescription {
    
    if (!self.userDescription.length) {
        return nil;
    }
    
    NSString* description = [self.userDescription stringByStrippingHTMLTags];
    
    NSArray* urls = self.entities[@"description"][@"urls"];
    for (NSDictionary* url in urls) {
        
        description = [description stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
    }
    
    return description;
}

#pragma mark -

+ (NSOperation*)requestUserWithId:(NSString*)userId completionBlock:(void (^)(UserEntity* user, NSError* error))block {
    
    NSParameterAssert(userId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"users/show.json" parameters:@{@"user_id": userId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        UserEntity* userEntity = [[UserEntity alloc] initWithDictionary:JSON];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(userEntity, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestUserWithScreenName:(NSString*)screenName completionBlock:(void (^)(UserEntity* user, NSError* error))block {
 
    NSParameterAssert(screenName);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"users/show.json" parameters:@{@"screen_name": screenName}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        UserEntity* userEntity = [[UserEntity alloc] initWithDictionary:JSON];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(userEntity, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestFollowersOfUser:(NSString*)userId cursor:(NSString*)cursor completionBlock:(void (^)(NSArray* followers, NSString* nextCursor, NSError* error))block {
    
    NSParameterAssert(userId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"user_id": userId};
    if (cursor) {
        NSMutableDictionary* mutableParams = [params mutableCopy];
        mutableParams[@"cursor"] = cursor;
        params = mutableParams;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"followers/list.json" parameters:params];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* followers = [[NSMutableArray alloc] initWithCapacity:[JSON[@"users"] count]];
        
        for (NSDictionary* userAsDictionary in JSON[@"users"]) {
            
            UserEntity* userEntity = [[UserEntity alloc] initWithDictionary:userAsDictionary];
            [followers addObject:userEntity];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(followers, [JSON[@"next_cursor"] description], nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)requestFriendsOfUser:(NSString*)userId cursor:(NSString*)cursor completionBlock:(void (^)(NSArray* friends, NSString* nextCursor,  NSError* error))block {
    
    NSParameterAssert(userId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"user_id": userId};
    if (cursor) {
        NSMutableDictionary* mutableParams = [params mutableCopy];
        mutableParams[@"cursor"] = cursor;
        params = mutableParams;
    }
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"friends/list.json" parameters:params];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* friends = [[NSMutableArray alloc] initWithCapacity:[JSON[@"users"] count]];
        
        for (NSDictionary* userAsDictionary in JSON[@"users"]) {
            
            UserEntity* userEntity = [[UserEntity alloc] initWithDictionary:userAsDictionary];
            [friends addObject:userEntity];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(friends, [JSON[@"next_cursor"] description], nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestFriendshipStatusWithUser:(NSString*)userId completionBlock:(void (^)(NSNumber* following, NSNumber* followedBy, NSError* error))block {
    
    NSParameterAssert(userId);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"friendships/show.json" parameters:@{@"source_id": self.userId, @"target_id": userId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(JSON[@"relationship"][@"source"][@"following"], JSON[@"relationship"][@"source"][@"followed_by"], nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestFollowingWithCompletionBlock:(void (^)(NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"friendships/create.json" parameters:@{@"user_id": self.userId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestUnfollowingWithCompletionBlock:(void (^)(NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"friendships/destroy.json" parameters:@{@"user_id": self.userId}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

+ (NSOperation*)searchUsersWithQuery:(NSString*)query count:(NSInteger)count page:(NSInteger)page completionBlock:(void (^)(NSArray* users, NSError* error))block {
    
    NSParameterAssert(query.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"users/search.json" parameters:@{@"q": query, @"count": @(count), @"page": @(page)}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* userAsDictionary in JSON) {
            
            UserEntity* user = [[UserEntity alloc] initWithDictionary:userAsDictionary];
            [users addObject:user];
        }
        
        block(users, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

@end
