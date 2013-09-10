//
//  FollowTweetilusService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowTweetilusService.h"
#import "UserEntity.h"

#define kFollowTweetilusOffered @"FollowTweetilusOffered"

@interface FollowTweetilusService () <UIAlertViewDelegate>

@end

@implementation FollowTweetilusService

+ (FollowTweetilusService*)sharedInstance {
    
    static FollowTweetilusService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FollowTweetilusService alloc] init];
    });
    
    return _sharedClient;
}

- (void)offerFollowingIfAppropriate {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kFollowTweetilusOffered]) {
        return; //user already accepted or declined the offer
    }
    
    UserEntity* user = [UserEntity currentUser];
    
    if (!user) {
        return;
    }
    
    [user requestFriendshipStatusWithUser:@"1611498181" completionBlock:^(NSNumber *following, NSNumber *followedBy, NSError *error) {
       
        if (error) {
            [[LogService sharedInstance] logError:error];
            return;
        }
        
        if (following.boolValue) {
            return; //already following
        }
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:kFollowTweetilusOffered]) {
            return; //user already accepted or declined the offer
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Follow @tweetilus?" message:@"Would you like to start following @tweetilus to stay in touch with the latest updates of the app? We're just getting started." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Follow", nil];
        [alertView show];
        
    }];
    
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kFollowTweetilusOffered];
    [userDefaults synchronize];
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    UserEntity* tweetilusUser = [UserEntity new];
    tweetilusUser.userId = @"1611498181";
    
    [tweetilusUser requestFollowingWithCompletionBlock:^(NSError *error) {
        
        if (error) {
            [[LogService sharedInstance] logError:error];
        }
    }];
}

@end
