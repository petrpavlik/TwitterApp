//
//  TweetService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/8/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetService.h"
#import "TweetEntity.h"
#import "UIAlertView+TwitterApp.h"

@interface TweetService () <UIAlertViewDelegate>

@end

@implementation TweetService

+ (TweetService*)sharedInstance {
    
    static TweetService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TweetService alloc] init];
    });
    
    return _sharedClient;
}

- (void)postTweetWithText:(NSString*)text asReplyToTweetId:(NSString*)tweetId location:(CLLocation*)location placeId:(NSString*)placeId media:(NSArray*)media {
    
    [TweetEntity requestStatusUpdateWithText:text asReplyToTweet:tweetId location:location placeId:placeId media:media completionBlock:^(TweetEntity *tweet, NSError *error) {
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            
            UIAlertView* alertViewiew = [[UIAlertView alloc] initWithTitle:@"Could not post Tweet" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            
            NSMutableDictionary* userInfo = [NSMutableDictionary new];
            userInfo[@"text"] = text;
            if (tweetId) {
                userInfo[@"asReplyToTweetId"] = tweetId;
            }
            if (location) {
                userInfo[@"location"] = location;
            }
            if (placeId) {
                userInfo[@"placeId"] = placeId;
            }
            if (media) {
                userInfo[@"media"] = media;
            }
            
            alertViewiew.userInfo = userInfo;
            
            [alertViewiew show];
        }
        else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidPostTweetNotification object:Nil];
        }
    }];
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    NSDictionary* tweetInfo = alertView.userInfo;
    NSParameterAssert(tweetInfo);
    
    [self postTweetWithText:tweetInfo[@"text"] asReplyToTweetId:tweetInfo[@"asReplyToTweetId"] location:tweetInfo[@"location"] placeId:tweetInfo[@"location"] media:tweetInfo[@"media"]];
}


@end
