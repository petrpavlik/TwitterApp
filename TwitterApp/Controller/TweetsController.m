//
//  TweetsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFTwitterClient.h"
#import "TweetsController.h"
#import "NotificationView.h"
#import "TweetsDataSource.h"
#import "LoadingCell.h"
#import "TweetDetailController.h"

typedef void (^BackgroundFetchCompletionBlock)(UIBackgroundFetchResult);

@interface TweetsController () <UIDataSourceModelAssociation, UIViewControllerRestoration>

@property(nonatomic) BOOL allTweetsLoaded;
@property(nonatomic, strong) TweetsDataSource* dataSource;
@property(nonatomic, strong) NSArray* tweets;
@property(nonatomic, strong) id didGainAccessObserver;
@property(nonatomic, strong) NSString* restoredIndexPathIdentifier;
@property(nonatomic, strong) BackgroundFetchCompletionBlock backgroundFetchCompletionBlock;

@end

@implementation TweetsController

- (NSString*)tweetsPersistenceIdentifier {
    return nil;
}

- (NSString*)stateRestorationIdentifier {
    return nil;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.didGainAccessObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadNewTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.refreshControl.tintColor = [UIColor blackColor];
    
    self.dataSource = [[TweetsDataSource alloc] initWithPersistenceIdentifier:self.tweetsPersistenceIdentifier];
    self.dataSource.delegate = self;
    
    self.restorationClass = [self class];
    self.restorationIdentifier = self.stateRestorationIdentifier;
    self.tableView.restorationIdentifier = @"TableView";
    
    __weak typeof(self) weakSelf = self;
    self.didGainAccessObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kDidGainAccessToAccountNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
       
        if (!weakSelf.tweets.count) {
            [weakSelf loadNewTweets];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([AFTwitterClient sharedClient].account) {
        
        if (!self.tweets.count) {
            [self.dataSource loadNewTweets];
        }
    }
}

#pragma mark -

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadNewTweets:(NSArray*)tweets cached:(BOOL)cached {
    
    NSParameterAssert(tweets);
    
    [self.refreshControl endRefreshing];
    
    if (!self.tweets.count) {
        
        self.tweets = tweets;
        [self.tableView reloadData];
        
        if (self.restoredIndexPathIdentifier) {
            
            NSInteger index = 0;
            for (TweetEntity* tweet in self.tweets) {
                
                if ([tweet.tweetId isEqual:self.restoredIndexPathIdentifier]) {
                    
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
                
                index++;
            }
            
            self.restoredIndexPathIdentifier = nil;
        }
        
        if (cached) {
            [self.dataSource loadNewTweets];
        }
        else {
            
            if (tweets.count) {
                
                if (self.backgroundFetchCompletionBlock) {
                    
                    self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNewData);
                    self.backgroundFetchCompletionBlock = nil;
                }
            }
            else {
                
                if (self.backgroundFetchCompletionBlock) {
                    
                    self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNoData);
                    self.backgroundFetchCompletionBlock = nil;
                }
            }
        }
    }
    else {
        
        if (tweets.count==0) {
            
            [NotificationView showInView:self.notificationViewPlaceholderView message:@"0 new tweets"];
            
            if (self.backgroundFetchCompletionBlock) {
                
                self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNoData);
                self.backgroundFetchCompletionBlock = nil;
            }
            
            return;
        }
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
            
            CGFloat contentOffsetY = self.tableView.contentOffset.y;
            
            [self.tableView reloadData];
            
            for (TweetEntity* tweet in tweets) {
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tweets indexOfObject:tweet] inSection:0];
                contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            }
            
            self.tableView.contentOffset = CGPointMake(0, contentOffsetY);
            
            NSInteger numOfNewTweets = tweets.count;
            if ([tweets.lastObject isKindOfClass:[GapTweetEntity class]]) {
                numOfNewTweets--;
            }
            
            [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%d new tweets", numOfNewTweets]];
            
            if (self.backgroundFetchCompletionBlock) {
                
                self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNewData);
                self.backgroundFetchCompletionBlock = nil;
            }
        });
    }
}

- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadNewTweetsWithError:(NSError*)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [self.refreshControl endRefreshing];
    
    if (self.backgroundFetchCompletionBlock) {
        
        self.backgroundFetchCompletionBlock(UIBackgroundFetchResultFailed);
        self.backgroundFetchCompletionBlock = nil;
    }
    else {
        
        [[[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFillGap:(GapTweetEntity *)gap withTweets:(NSArray *)tweets {
    
    NSInteger indexOfGapTweet = [self.tweets indexOfObject:gap];
    NSMutableArray* mutableTimeline = [self.tweets mutableCopy];
    
    [mutableTimeline removeObjectAtIndex:indexOfGapTweet];
    
    NSInteger indexForTweet = indexOfGapTweet;
    for (TweetEntity* tweetToInsert in tweets) {
        
        [mutableTimeline insertObject:tweetToInsert atIndex:indexForTweet];
        indexForTweet++;
    }
    
    
    self.tweets = mutableTimeline;
    [self.tableView reloadData];
}

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadOldTweets:(NSArray*)tweets {
    
    NSParameterAssert(tweets);
    
    if (tweets.count) {
        
        self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
        
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
        [self.tableView beginUpdates];
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:1];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [NotificationView showInView:self.notificationViewPlaceholderView message:@"All tweets loaded"];
    }
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFailToLoadOldTweetsWithError:(NSError *)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [[[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    @throw [NSException exceptionWithName:@"MustOverloadedException" reason:@"this method muse be overloaded" userInfo:nil];
    return nil;
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
        [self.dataSource loadTweetsForGap:gapTweet];
    }
    else {
        
        TweetDetailController* tweetDetailController = [[TweetDetailController alloc] initWithStyle:UITableViewStylePlain];
        tweetDetailController.tweet = tweet;
         
        [self.navigationController pushViewController:tweetDetailController animated:YES];
    }
}

#pragma mark -

- (TweetEntity*)tweetForIndexPath:(NSIndexPath *)indexPath {
    return self.tweets[indexPath.row];
}

- (void)loadNewTweets {
    
    [self.dataSource loadNewTweets];
}

#pragma mark - state restoration

+ (UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    UIViewController* tweetsController = [[[self class] alloc] init];
    return tweetsController;
}

- (NSString*)modelIdentifierForElementAtIndexPath:(NSIndexPath*)idx inView:(UIView*)view {
    
    TweetEntity* tweet = self.tweets[idx.row];
    return tweet.tweetId;
}

- (NSIndexPath*)indexPathForElementWithModelIdentifier:(NSString*)identifier inView:(UIView*)view {
    
    if (!self.tweets) {
        
        //model has not been loaded yet
        self.restoredIndexPathIdentifier = [identifier copy];
        return nil;
    }
    
    NSInteger index = 0;
    for (TweetEntity* tweet in self.tweets) {
        
        if ([tweet.tweetId isEqual:identifier]) {
            return [NSIndexPath indexPathForRow:index inSection:0];
        }
        
        index++;
    }
    
    return nil;
}

#pragma mark -

- (void)fetchNewTweetsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if (!self.dataSource.isReady || [self.dataSource loadNewTweets]) {
        self.backgroundFetchCompletionBlock = completionHandler;
    }
    else {
        completionHandler(UIBackgroundFetchResultNoData); //most likely currently already loading new tweets
    }
}


@end
