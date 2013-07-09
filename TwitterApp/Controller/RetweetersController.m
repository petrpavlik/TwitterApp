//
//  RetweetersController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "RetweetersController.h"
#import "TweetEntity.h"

@interface RetweetersController ()

@end

@implementation RetweetersController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.tweetId);
    
    self.title = @"Retweets";
}

- (NSOperation*)dataRequestOperationWithCursor:(NSString *)cursor completionBlock:(void (^)(NSArray *users, NSString *cursor, NSError *error))completionBlock {
    
    return [TweetEntity requestRetweetsOfTweet:self.tweetId completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            completionBlock(Nil, Nil, error);
        }
        else {
            
            NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:tweets.count];
            for (TweetEntity* tweet in tweets) {
                [users addObject:tweet.user];
            }
            
            completionBlock(users, Nil, error);
        }
    }];
}


@end
