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
#import "LoadingCell.h"

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
        [self requestOlderRelatedTweets];
    }
    else {
        self.olderRelatedTweets = [NSArray new];
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
        
        if (self.replies == nil) {
            return 1;
        }
        else {
            NSLog(@"num replies %lu", (unsigned long)self.replies.count);
            return self.replies.count;
        }
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        
        if (self.olderRelatedTweets == nil && self.tweet.inReplyToStatusId) {
            return 1;
        }
        else {
            return self.olderRelatedTweets.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        
        TweetEntity* tweet = [self tweetForIndexPath:indexPath];
        UITableViewCell* cell = [self cellForTweetDetail:tweet atIndexPath:indexPath];
        //UITableViewCell* cell =  [self cellForTweet:tweet atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if (indexPath.section == 2) {
        
        if (self.olderRelatedTweets == Nil) {
            return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        }
        else {
            TweetEntity* tweet = [self tweetForIndexPath:indexPath];
            return [self cellForTweet:tweet atIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 0) {
        
        if (self.replies == Nil) {
            return [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        }
        else {
            TweetEntity* tweet = [self tweetForIndexPath:indexPath];
            return [self cellForTweet:tweet atIndexPath:indexPath];
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==1) {
        
        TweetEntity* tweet = [self tweetForIndexPath:indexPath];
        return [self heightForTweetDetail:tweet];
    }
    else if (indexPath.section == 2) {
        
        if (self.olderRelatedTweets == Nil) {
            return 44;
        }
        else {
            
            TweetEntity* tweet = [self tweetForIndexPath:indexPath];
            return [self heightForTweet:tweet];
        }
    }
    else if (indexPath.section == 0) {
        
        if (self.replies == Nil) {
            return 44;
        }
        else {
            
            TweetEntity* tweet = [self tweetForIndexPath:indexPath];
            return [self heightForTweet:tweet];
        }
    }

    return 0;
}

/*- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section==2) {
        
        CGFloat heightOfContent = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        for (NSInteger i=0; i<self.olderRelatedTweets.count; i++) {
            heightOfContent += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
        }
        
        heightOfContent += self.tabBarController.tabBar.frame.size.height;
        
        CGFloat padding = MAX(0, self.tableView.bounds.size.height - heightOfContent);
        
        if (self.olderRelatedTweets == nil) {
            padding -= 44;
        }
        
        return padding;
    }
    else {
        return 0;
    }
}*/

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
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
            weakSelf.replies = [NSArray new];
            return;
        }
        
        weakSelf.tableView.userInteractionEnabled = NO;
        
        weakSelf.replies = [NSArray new];
        
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf.tableView endUpdates];
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            weakSelf.tableView.userInteractionEnabled = YES;
            
            weakSelf.replies = tweets;
            
            CGFloat heightOfContent = 0;
            for (NSInteger i=0; i<tweets.count; i++) {
                heightOfContent += [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            CGFloat contentOffset = weakSelf.tableView.contentOffset.y;
            contentOffset += heightOfContent;
            
            [weakSelf.tableView reloadData];
            weakSelf.tableView.contentOffset = CGPointMake(weakSelf.tableView.contentOffset.x, contentOffset);
            
            //NSLog(@"%f %f", self.tableView.contentOffset.y, self.tableView.contentSize.height);
            
            CGFloat heightOfTweetDetailCell = [weakSelf tableView:weakSelf.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            if (heightOfTweetDetailCell < weakSelf.tableView.bounds.size.height) {
                
                CGFloat difference = weakSelf.tableView.bounds.size.height - heightOfTweetDetailCell - weakSelf.tableView.contentInset.bottom;
                
                if (heightOfContent > 0) {
                    
                    if (heightOfContent < difference) {
                        difference = heightOfContent;
                    }
                    
                    [weakSelf.tableView setContentOffset:CGPointMake(weakSelf.tableView.contentOffset.x, weakSelf.tableView.contentOffset.y - difference) animated:YES];
                }
            }
            
            /*if (weakSelf.replies.count) {
                
                [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%d replies", tweets.count] style:NotificationViewStyleInformation];
                [weakSelf.tableView flashScrollIndicators];
            }*/
        });
        
        /*[weakSelf.tableView beginUpdates];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf.tableView endUpdates];
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];*/
        
        //[weakSelf.tableView flashScrollIndicators];
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
            //[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
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
            
            weakSelf.olderRelatedTweets = [NSArray new];
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
            
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
            //[weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            if ([weakSelf.olderRelatedTweets.lastObject inReplyToStatusId]) {
                
                [weakSelf requestOlderRelatedTweetToTweetId:[weakSelf.olderRelatedTweets.lastObject inReplyToStatusId]];
            }
        }
        else {
            
            weakSelf.olderRelatedTweets = [NSArray new];
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
            
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
