//
//  TweetDetailController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NSString+TwitterApp.h"
#import "TweetCell.h"
#import "TweetDetailController.h"
#import "TweetEntity.h"

@interface TweetDetailController ()

@property(nonatomic, strong) NSArray* olderRelatedTweets;
@property(nonatomic, strong) NSArray* replies;
@property(nonatomic, weak) NSOperation* runningOlderRelatedTweetRequest;
@property(nonatomic, weak) NSOperation* runningRepliesRequest;

@end

@implementation TweetDetailController

- (void)dealloc {

    [self.runningOlderRelatedTweetRequest cancel];
    [self.runningRepliesRequest cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert(self.tweet);
    
    self.title = @"Tweet Detail";
    
    [self requestReplies];
    
    if (self.tweet.inReplyToStatusId) {
        [self requestOlderRelatedTweetToTweetId:self.tweet.inReplyToStatusId];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0) {
        return self.replies.count;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return self.olderRelatedTweets.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    return [self cellForTweet:tweet atIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    return [self heightForTweet:tweet];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark -

- (void)requestReplies {
    
    __weak typeof(self) weakSelf = self;
    
    [TweetEntity requestSearchRepliesWithTweetId:self.tweet.tweetId screenName:self.tweet.user.screenName completionBlock:^(NSArray *tweets, NSError *error) {
        
        weakSelf.replies = tweets;
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestOlderRelatedTweetToTweetId:(NSString*)tweetId {
    
    NSParameterAssert(tweetId);
    
    __weak typeof(self) weakSelf = self;
    
    self.runningOlderRelatedTweetRequest = [TweetEntity requestTweetWithId:tweetId completionBlock:^(TweetEntity *tweet, NSError *error) {
       
        if (tweet) {
            
            if (!weakSelf.olderRelatedTweets) {
                weakSelf.olderRelatedTweets = @[tweet];
            }
            else {
                weakSelf.olderRelatedTweets = [weakSelf.olderRelatedTweets arrayByAddingObject:tweet];
            }
            
            [self.tableView reloadData];
            
            if (tweet.inReplyToStatusId) {
                [weakSelf requestOlderRelatedTweetToTweetId:tweetId];
            }
        }
    }];
}

#pragma mark -

- (TweetEntity*)tweetForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return self.replies[indexPath.row];
    }
    else if (indexPath.section == 1) {
        return self.tweet;
    }
    else if (indexPath.section == 2) {
        return self.olderRelatedTweets[indexPath.row];
    }
    else {
        NSAssert(NO, @"unknown section index");
    }
    
    return nil;
}

@end
