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
@property(nonatomic, weak) NSOperation* runningRepliesRequest;

@end

@implementation TweetDetailController

- (UIView*)notificationViewPlaceholderView {
    
    if (!_notificationViewPlaceholderView) {
        
        _notificationViewPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        _notificationViewPlaceholderView.backgroundColor = [UIColor redColor];
        _notificationViewPlaceholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //_notificationViewPlaceholderView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_notificationViewPlaceholderView];
    }
    
    return _notificationViewPlaceholderView;
}

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
    
    if (indexPath.section==1) {
        return [self cellForTweetDetail:tweet atIndexPath:indexPath];
    }
    else {
        return [self cellForTweet:tweet atIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    
    if (indexPath.section==1) {
        return [self heightForTweetDetail:tweet];
    }
    else {
        return [self heightForTweet:tweet];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section==1) {
        
        CGFloat heightOfContent = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        for (NSInteger i=0; i<self.olderRelatedTweets.count; i++) {
            heightOfContent += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        CGFloat padding = MAX(0, self.tableView.bounds.size.height - heightOfContent);
        
        return padding;
    }
    else {
        return 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UIEdgeInsets insets =  self.tableView.contentInset;
    self.notificationViewPlaceholderView.center = CGPointMake(self.notificationViewPlaceholderView.center.x, scrollView.contentOffset.y+self.notificationViewPlaceholderView.frame.size.height/2 + insets.top);
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
        
        [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%d replies", tweets.count] style:NotificationViewStyleInformation];
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
            
            if (tweet.inReplyToStatusId && ![tweet.inReplyToStatusId isEqualToString:tweet.tweetId]) { //second condition should never be YES, but I rather added it
                [weakSelf requestOlderRelatedTweetToTweetId:tweet.inReplyToStatusId];
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
