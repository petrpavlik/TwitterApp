//
//  TweetDetailController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NotificationView.h"
#import "NSString+TwitterApp.h"
#import "TweetCell.h"
#import "TweetDetailController.h"
#import "TweetEntity.h"

@interface TweetDetailController ()

@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, strong) NSArray* olderRelatedTweets;
@property(nonatomic, strong) NSArray* replies;
@property(nonatomic, weak) NSOperation* runningOlderRelatedTweetRequest;
@property(nonatomic, weak) NSOperation* runningOlderRelatedTweetsRequest;
@property(nonatomic, weak) NSOperation* runningRepliesRequest;

@end

@implementation TweetDetailController

- (void)dealloc {

    [self.runningOlderRelatedTweetRequest cancel];
    [self.runningRepliesRequest cancel];
    [self.runningOlderRelatedTweetsRequest cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert(self.tweet);
    
    self.title = @"Tweet Detail";
    
    [self requestReplies];
    
    if (self.tweet.inReplyToStatusId) {
        
        //[self requestOlderRelatedTweetToTweetId:self.tweet.inReplyToStatusId];
        [self requestOlderRelatedTweets];
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
    
    if (indexPath.section==1) {
        //return [self cellForTweetDetail:tweet atIndexPath:indexPath];
        UITableViewCell* cell =  [self cellForTweet:tweet atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else {
        return [self cellForTweet:tweet atIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    
    if (indexPath.section==1) {
        //return [self heightForTweetDetail:tweet];
        return [self heightForTweet:tweet];
    }
    else {
        return [self heightForTweet:tweet];
    }
}

/*- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}*/

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section==2) {
        
        CGFloat heightOfContent = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        for (NSInteger i=0; i<self.olderRelatedTweets.count; i++) {
            heightOfContent += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        heightOfContent += self.tabBarController.tabBar.frame.size.height;
        
        CGFloat padding = MAX(0, self.tableView.bounds.size.height - heightOfContent);
        
        return padding;
    }
    else {
        return 0;
    }
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section==3) {
        
        CGFloat heightOfContent = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        for (NSInteger i=0; i<self.olderRelatedTweets.count; i++) {
            heightOfContent += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        heightOfContent += self.tabBarController.tabBar.frame.size.height;
        
        CGFloat padding = MAX(0, self.tableView.bounds.size.height - heightOfContent);
        
        return padding;
    }
    else {
        return 0;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    TweetEntity* tweet = Nil;
    if (indexPath.section == 0) {
        tweet = self.replies[indexPath.row];
    }
    else if (indexPath.section == 2) {
        tweet = self.olderRelatedTweets[indexPath.row];
    }
    
    NSParameterAssert(tweet);
    
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    TweetDetailController* tweetDetailController = [[TweetDetailController alloc] initWithStyle:UITableViewStylePlain];
    tweetDetailController.tweet = tweet;
    
    [self.navigationController pushViewController:tweetDetailController animated:YES];
}


#pragma mark -

- (void)requestReplies {
    
    __weak typeof(self) weakSelf = self;
    
    [TweetEntity requestSearchRepliesWithTweetId:self.tweet.tweetId screenName:self.tweet.user.screenName completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:@"Could not load replies" style:NotificationViewStyleError];
            return;
        }
        
        weakSelf.replies = tweets;
        
        CGFloat heightOfContent = 0;
        for (NSInteger i=0; i<tweets.count; i++) {
            heightOfContent += [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        CGFloat contentOffset = weakSelf.tableView.contentOffset.y;
        contentOffset += heightOfContent;
        
        [weakSelf.tableView reloadData];
        weakSelf.tableView.contentOffset = CGPointMake(weakSelf.tableView.contentOffset.x, contentOffset);
        
        [weakSelf.tableView reloadData];
        
        if (tweets.count) {
            
            [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%d replies", tweets.count] style:NotificationViewStyleInformation];
        }
        
        [weakSelf.tableView flashScrollIndicators];
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
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.olderRelatedTweets.count-1 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
            
            //[weakSelf.tableView reloadData];
            
            if (tweet.inReplyToStatusId && ![tweet.inReplyToStatusId isEqualToString:tweet.tweetId]) { //second condition should never be YES, but I rather added it
                [weakSelf requestOlderRelatedTweetToTweetId:tweet.inReplyToStatusId];
            }
        }
    }];
}

- (void)requestOlderRelatedTweets {
    
    __weak typeof(self) weakSelf = self;
    
    self.runningOlderRelatedTweetsRequest = [TweetEntity requestSearchOlderRelatedTweetsWithTweet:self.tweet screenName:self.tweet.user.screenName completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (error) {
            //TODO: handle error
            return;
        }
        
        if (tweets.count) {
            
            if (!weakSelf.olderRelatedTweets) {
                weakSelf.olderRelatedTweets = tweets;
            }
            else {
                weakSelf.olderRelatedTweets = [weakSelf.olderRelatedTweets arrayByAddingObjectsFromArray:tweets];
            }
            
            //[self.tableView reloadData];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
            
            if ([weakSelf.olderRelatedTweets.lastObject inReplyToStatusId]) {
                
                [weakSelf requestOlderRelatedTweetToTweetId:[weakSelf.olderRelatedTweets.lastObject inReplyToStatusId]];
            }
        }
        else {
           
            [weakSelf requestOlderRelatedTweetToTweetId:[weakSelf.tweet inReplyToStatusId]];
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
