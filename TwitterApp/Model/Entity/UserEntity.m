//
//  UserEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
#import "AFTwitterClient.h"
#import "UserEntity.h"

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

#pragma mark -

+ (void)registerCurrentUser:(UserEntity *)user {
    currentUser = user;
}

+ (UserEntity*)currentUser {
    return currentUser;
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

@end
