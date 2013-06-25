//
//  PlaceEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"
#import <MapKit/MapKit.h>

@interface PlaceEntity : BaseEntity

@property(nonatomic, strong) NSString* fullName;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* placeId;

+ (NSOperation*)requestPlacesWithLocation:(CLLocation*)location completionBlock:(void (^)(NSArray* places, NSError* error))block;

@end
