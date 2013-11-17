//
//  TweetMarkerEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 31/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"

@interface TweetMarkerEntity : BaseEntity

@property(nonatomic, strong) NSString* tweetId;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSNumber* version;

+ (NSOperation*)requestTweetMarkersWithUsername:(NSString*)username completionHandler:(void (^)(TweetMarkerEntity* tweetMarker, NSError* error))block;

@end
