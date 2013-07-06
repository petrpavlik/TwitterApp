//
//  FavoritesController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/6/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FavoritesController.h"
#import "LoadingCell.h"
#import "NotificationView.h"
#import "TweetsDataSource.h"

@interface FavoritesController () <TweetDataSourceDelegate>

@property(nonatomic) BOOL allTweetsLoaded;
@property(nonatomic, strong) TweetsDataSource* dataSource;
@property(nonatomic, strong) NSArray* tweets;

@end

@implementation FavoritesController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Favorites";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadNewTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.refreshControl.tintColor = [UIColor blackColor];
    
    self.dataSource = [[TweetsDataSource alloc] initWithPersistenceIdentifier:Nil];
    self.dataSource.delegate = self;
    [self.dataSource loadNewTweets];
}

#pragma mark -

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadNewTweets:(NSArray*)tweets {
    
    NSParameterAssert(tweets);
    
    [self.refreshControl endRefreshing];
    
    if (!self.tweets.count) {
        self.tweets = tweets;
    }
    else {
        self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
        
        [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%d new tweets", tweets.count]];
    }
    
    [self.tableView reloadData];
}

- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadNewTweetsWithError:(NSError*)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [self.refreshControl endRefreshing];
    [[[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadOldTweets:(NSArray*)tweets {
    
    NSParameterAssert(tweets);
    
    if (tweets.count) {
        
        [self.tableView beginUpdates];
        
        NSMutableArray* indexPaths = [[NSMutableArray alloc] initWithCapacity:tweets.count];
        for (NSInteger i=0; i<tweets.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.tweets.count-tweets.count+i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    else {
        
        self.allTweetsLoaded = YES;
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:1];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        
        [NotificationView showInView:self.notificationViewPlaceholderView message:@"All tweets loaded"];
    }
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFailToLoadOldTweetsWithError:(NSError *)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [[[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestMentionsTimelineWithMaxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.allTweetsLoaded) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (self.tweets.count==0) {
        return 0;
    }
    
    if (section==0) {
        return self.tweets.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
        TweetEntity* tweet = self.tweets[indexPath.row];
        return [self cellForTweet:tweet atIndexPath:indexPath];
    }
    else {
        
        [self.dataSource loadOldTweets];
        
        static NSString *CellIdentifier = @"LoadingCell";
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        TweetEntity* tweet = self.tweets[indexPath.row];
        return [self heightForTweet:tweet];
    }
    else {
        
        return 44;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    if ([tweet isKindOfClass:[GapTweetEntity class]]) {
        
        GapTweetEntity* gapTweet = (GapTweetEntity*)tweet;
        gapTweet.loading = @(YES);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        //[self requestTweetsSinceId:[self.tweets[indexPath.row+1] tweetId] withMaxId:[self.tweets[indexPath.row-1] tweetId]];
    }
    else {
        
        /*TweetDetailController* tweetDetailController = [[TweetDetailController alloc] initWithStyle:UITableViewStylePlain];
         tweetDetailController.tweet = tweet;
         
         [self.navigationController pushViewController:tweetDetailController animated:YES];*/
    }
}

#pragma mark -

- (TweetEntity*)tweetForIndexPath:(NSIndexPath *)indexPath {
    return self.tweets[indexPath.row];
}

- (void)loadNewTweets {
    
    [self.dataSource loadNewTweets];
}

@end
