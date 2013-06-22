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

- (NSOperation*)dataRequestOperation {
    
    __weak typeof(self) weakSelf = self;
    
    return [TweetEntity requestRetweetsOfTweet:self.tweetId completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            weakSelf.errorMessage = error.description;
        }
        else if (!tweets.count) {
            weakSelf.errorMessage = @"No retweets found";
        }
        else {
            
            NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:tweets.count];
            for (TweetEntity* tweet in tweets) {
                [users addObject:tweet.user];
            }
            
            weakSelf.users = users;
        }
    }];
}

@end
