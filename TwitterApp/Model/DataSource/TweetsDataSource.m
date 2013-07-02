//
//  TweetsDataSource.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetsDataSource.h"

@interface TweetsDataSource ()

@property(nonatomic, strong) NSArray* tweets;
@property(nonatomic, weak) NSOperation* runningNewTweetsOperation;
@property(nonatomic, weak) NSOperation* runningOldTweetsOperation;

@end

@implementation TweetsDataSource

- (void)dealloc {
    
    self.runningNewTweetsOperation = nil;
    self.runningOldTweetsOperation = nil;
}

- (NSArray*)tweets {
    
    if (!_tweets) {
        _tweets = @[];
    }
    
    return _tweets;
}

- (void)loadNewTweets {
    
    if (self.runningNewTweetsOperation) {
        return;
    }
    
    NSString* sinceId = nil;
    
    if (self.tweets.count) {
        
        //we want out most recent tweet to be eventually returned again in order to detect a gap
        long long sinceIdLong = [sinceId longLongValue];
        sinceIdLong -= 1;
        sinceId = @(sinceIdLong).description;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSParameterAssert(self.delegate);
    
    self.runningNewTweetsOperation = [self.delegate tweetDataSource:self requestForTweetsSinceId:sinceId withMaxId:nil completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            
            [weakSelf.delegate tweetDataSource:weakSelf didFailToLoadNewTweetsWithError:error];
        }
        else {
            
            if (weakSelf.tweets.count) {
                
                NSMutableArray* mutableNewTweets = [tweets mutableCopy];
                
                if ([[mutableNewTweets.lastObject tweetId] isEqualToString:[weakSelf.tweets[0] tweetId]]) {
                    
                    //no gap detected
                    NSLog(@"no gap detected");
                    [mutableNewTweets removeLastObject];
                }
                else {
                    
                    //gap detected
                    NSLog(@"gap detected");
                    
                    [mutableNewTweets removeLastObject];
                    [mutableNewTweets addObject:[GapTweetEntity new]];
                }
                
                tweets = mutableNewTweets;
            }
            else {
                weakSelf.tweets = tweets;
            }
            
            weakSelf.tweets = [tweets arrayByAddingObjectsFromArray:weakSelf.tweets];
            [weakSelf.delegate tweetDataSource:weakSelf didLoadNewTweets:tweets];
        }
    }];
    
    NSParameterAssert(self.runningNewTweetsOperation);
}

- (void)loadOldTweets {
 
    NSParameterAssert(self.tweets.count);
    
    if (self.runningOldTweetsOperation) {
        return;
    }
    
    NSString* maxId = [self.tweets.lastObject tweetId];
    
    //we dodn't really want the maxId tweet to be returned again
    long long maxIdLong = [maxId longLongValue];
    maxIdLong -= 1;
    maxId = @(maxIdLong).description;
    
    __weak typeof(self) weakSelf = self;
    
    NSParameterAssert(self.delegate);
    
    self.runningOldTweetsOperation = [self.delegate tweetDataSource:self requestForTweetsSinceId:nil withMaxId:maxId completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            
            [weakSelf.delegate tweetDataSource:weakSelf didFailToLoadOldTweetsWithError:error];
        }
        else {
            
            NSParameterAssert(weakSelf.tweets);
            weakSelf.tweets = [weakSelf.tweets arrayByAddingObjectsFromArray:tweets];
            [weakSelf.delegate tweetDataSource:weakSelf didLoadOldTweets:tweets];
        }
    }];
    
    NSParameterAssert(self.runningOldTweetsOperation);
}

@end
