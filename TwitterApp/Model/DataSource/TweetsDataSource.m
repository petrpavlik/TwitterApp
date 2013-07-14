//
//  TweetsDataSource.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "GapTweetEntity.h"
#import "TimelineDocument.h"
#import "TweetsDataSource.h"

@interface TweetsDataSource () <TimelineDocumentDelegate>

@property(nonatomic, strong) NSString* persistenceIdentifier;
@property(nonatomic, weak) NSOperation* runningNewTweetsOperation;
@property(nonatomic, weak) NSOperation* runningOldTweetsOperation;
@property(nonatomic, strong) TimelineDocument* document;
@property(nonatomic, strong) NSArray* tweets;
@property(nonatomic, getter = isTaskInProgress) BOOL taskInProgress;

@end

@implementation TweetsDataSource

- (void)dealloc {
    
    [self.runningNewTweetsOperation cancel];
    [self.runningOldTweetsOperation cancel];
}

- (instancetype)initWithPersistenceIdentifier:(NSString*)persistenceIdentifier {
    
    self = [super init];
    if (self) {
        
        self.persistenceIdentifier = persistenceIdentifier;
    }
    return self;
}

- (NSArray*)tweets {
    
    if (!_tweets) {
        _tweets = @[];
    }
    
    return _tweets;
}

- (void)loadNewTweets {
    
    if (self.isTaskInProgress) {
        return;
    }
    
    self.taskInProgress = YES;
    
    if (self.persistenceIdentifier && !self.document) {
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *dataFile = [docsDir stringByAppendingPathComponent:self.persistenceIdentifier];
        NSURL* documentUrl = [NSURL fileURLWithPath:dataFile];
        
        self.document = [[TimelineDocument alloc] initWithFileURL:documentUrl];
        self.document.delegate = self;
        
        [self.document openAsync];
    }
    else {
        
        NSString* sinceId = nil;
        
        if (self.tweets.count) {
            
            sinceId = [self.tweets.firstObject tweetId];
            
            //we want out most recent tweet to be eventually returned again in order to detect a gap
            long long sinceIdLong = [sinceId longLongValue];
            sinceIdLong -= 1;
            sinceId = @(sinceIdLong).description;
        }
        
        __weak typeof(self) weakSelf = self;
        
        NSParameterAssert(self.delegate);
        
        self.taskInProgress = YES;
        
        self.runningNewTweetsOperation = [self.delegate tweetDataSource:self requestForTweetsSinceId:sinceId withMaxId:nil completionBlock:^(NSArray *tweets, NSError *error) {
            
            self.taskInProgress = NO;
            
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
                [weakSelf.document persistTimeline:weakSelf.tweets];
            }
        }];
        
        NSParameterAssert(self.runningNewTweetsOperation);
    }
}

- (void)loadOldTweets {
 
    NSParameterAssert(self.tweets.count);
    
    if (self.isTaskInProgress) {
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
        
        self.taskInProgress = NO;
        
        if (error) {
            
            [weakSelf.delegate tweetDataSource:weakSelf didFailToLoadOldTweetsWithError:error];
        }
        else {
            
            NSParameterAssert(weakSelf.tweets);
            weakSelf.tweets = [weakSelf.tweets arrayByAddingObjectsFromArray:tweets];
            [weakSelf.delegate tweetDataSource:weakSelf didLoadOldTweets:tweets];
            [weakSelf.document persistTimeline:weakSelf.tweets];
        }
    }];
    
    NSParameterAssert(self.runningOldTweetsOperation);
}

- (void)deleteTweet:(TweetEntity*)tweet {
    
    NSParameterAssert(tweet);
    
    __weak typeof(self) weakSelf = self;
    
    [TweetEntity requestDeletionOfTweetWithId:tweet.tweetId completionBlock:^(NSError *error) {
        
        if (error) {
            [weakSelf.delegate tweetDataSource:weakSelf didFailToDeleteTweetWithError:error];
        }
        
        [weakSelf.delegate tweetDataSource:self didDeleteTweet:tweet];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTweetDeletedNotification object:Nil userInfo:@{@"tweet": tweet}];
    }];
}

- (void)loadTweetsForGap:(GapTweetEntity*)gap {
    
    NSParameterAssert(gap);
    NSParameterAssert([gap isKindOfClass:[GapTweetEntity class]]);
    
    NSInteger indexOfGapTweet = [self.tweets indexOfObject:gap];
    NSAssert(indexOfGapTweet != NSNotFound, @"gap tweet not found in the timeline");
    
    NSString *maxId = [self.tweets[indexOfGapTweet-1] tweetId];
    NSString *sinceId = [self.tweets[indexOfGapTweet+1] tweetId];
    
    long long maxIdLong = [maxId longLongValue];
    maxIdLong -= 1;
    maxId = @(maxIdLong).description;
    
    long long sinceIdLong = [sinceId longLongValue];
    sinceIdLong -= 1;
    sinceId = @(sinceIdLong).description;
    
    __weak typeof(self) weakSelf = self;

    self.runningOldTweetsOperation = [self.delegate tweetDataSource:self requestForTweetsSinceId:sinceId withMaxId:maxId completionBlock:^(NSArray *tweets, NSError *error) {
        
        self.taskInProgress = NO;
        
        if (error) {
            
            [weakSelf.delegate tweetDataSource:weakSelf didFailToFillGap:gap error:error];
        }
        else {
            
            NSParameterAssert(weakSelf.tweets);
            
            /*NSInteger indexOfGapTweet = [weakSelf.tweets indexOfObject:gap];
            NSMutableArray* mutableTweets = [self.tweets mutableCopy];
            
            for (TweetEntity* tweetToAdd in tweets) {
                
                if (tweetToAdd == tweets.lastObject) {
                    
                    if ([tweetToAdd.tweetId isEqualToString:[mutableTweets[index] tweetId]]) {
                        
                        //no gap
                    }
                    else {
                        
                        [mutableTweets insertObject:[GapTweetEntity new] atIndex:index];
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                        index++;
                    }
                }
                else {
                    
                    [mutableTweets insertObject:tweetToAdd atIndex:indexOfGapTweet];
                    indexOfGapTweet++;
                }
            }
            
            self.tweets = mutableTweets;
            
            weakSelf.tweets = [weakSelf.tweets arrayByAddingObjectsFromArray:tweets];
            [weakSelf.delegate tweetDataSource:weakSelf didLoadOldTweets:tweets];
            [weakSelf.document persistTimeline:weakSelf.tweets];*/
        }
    }];
}

#pragma mark -

- (void)timelineDocumentDidLoadPersistedTimeline:(NSArray *)tweets {
    
    self.taskInProgress = NO;
    
    if (tweets.count) {
        
        self.tweets = tweets;
        [self.delegate tweetDataSource:self didLoadNewTweets:tweets];
    }
    else {
        
        [self loadNewTweets];
    }
}

@end