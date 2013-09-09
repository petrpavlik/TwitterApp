//
//  TweetService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 9/8/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TweetService : NSObject

+ (TweetService*)sharedInstance;

- (void)postTweetWithText:(NSString*)text asReplyToTweetId:(NSString*)tweetId location:(CLLocation*)location placeId:(NSString*)placeId media:(NSArray*)media;

@end
