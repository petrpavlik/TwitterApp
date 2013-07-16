//
//  SavedSearchEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"

@interface SavedSearchEntity : BaseEntity

@property(nonatomic, strong) NSDate* createdAt;
@property(nonatomic, strong) NSString* savedSearchId;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* query;

+ (NSOperation*)requestSavedSearchSave:(NSString*)query completionBlock:(void (^)(SavedSearchEntity* savedSearch, NSError* error))block;
+ (NSOperation*)requestSavedSearchesWithCompletionBlock:(void (^)(NSArray* savedSearches, NSError* error))block;
- (NSOperation*)requestSavedSearchDestroyWithCompletionBlock:(void (^)(NSError* error))block;

@end
