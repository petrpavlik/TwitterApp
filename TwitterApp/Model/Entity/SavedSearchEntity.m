//
//  SavedSearchEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
#import "AFTwitterClient.h"
#import "SavedSearchEntity.h"

@implementation SavedSearchEntity

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"CreatedAt"] && ![value isKindOfClass:[NSDate class]]) {
        
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
        
        self.savedSearchId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

#pragma mark -

+ (NSOperation*)requestSavedSearchSave:(NSString*)query completionBlock:(void (^)(SavedSearchEntity* savedSearch, NSError* error))block {
    
    NSParameterAssert(query.length);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:@"saved_searches/create.json" parameters:@{@"query": query}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        SavedSearchEntity* savedSearch = [[SavedSearchEntity alloc] initWithDictionary:JSON];
        block(savedSearch, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
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

+ (NSOperation*)requestSavedSearchesWithCompletionBlock:(void (^)(NSArray* savedSearches, NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"saved_searches/list.json" parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSMutableArray* savedSearches = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        
        for (NSDictionary* savedSearchAsDictionary in JSON) {
            
            SavedSearchEntity* savedSearch = [[SavedSearchEntity alloc] initWithDictionary:savedSearchAsDictionary];
            [savedSearches addObject:savedSearch];
        }
        
        block(savedSearches, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (NSOperation*)requestSavedSearchDestroyWithCompletionBlock:(void (^)(NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"saved_searches/destroy/%@.json", self.savedSearchId] parameters:nil];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(error);
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        
        block([NSError errorWithDomain:prodName code:0 userInfo:@{NSLocalizedDescriptionKey: @"Background task for this operation expired before the operation was completed."}]);
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

@end
