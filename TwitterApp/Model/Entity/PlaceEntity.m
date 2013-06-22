//
//  PlaceEntity.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
#import "AFTwitterClient.h"
#import "PlaceEntity.h"

@implementation PlaceEntity

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"Id"]) {
        
        self.placeId = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

#pragma mark -

+ (NSOperation*)requestPlacesWithLocation:(CLLocation*)location completionBlock:(void (^)(NSArray* places, NSError* error))block {
    
    NSParameterAssert(location);
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSMutableURLRequest *request = [apiClient signedRequestWithMethod:@"GET" path:@"geo/reverse_geocode.json" parameters:@{@"lat": @(location.coordinate.latitude), @"long": @(location.coordinate.longitude)}];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        JSON = JSON[@"result"][@"places"];
        
        NSMutableArray* places = [[NSMutableArray alloc] initWithCapacity:[JSON count]];
        for (NSDictionary* placeJSON in JSON) {
            
            PlaceEntity* place = [[PlaceEntity alloc] initWithDictionary:placeJSON];
            [places addObject:place];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(places, nil);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil, error);
    }];
    
    [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

@end
