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
#import "TweetMarkerEntity.h"
#import "UserService.h"
#import "SettingsService.h"

typedef void (^BackgroundFetchCompletionBlock)(UIBackgroundFetchResult);

@interface TweetsController () <UIViewControllerRestoration>

@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic) BOOL allTweetsLoaded;
@property(nonatomic, strong) TweetsDataSource* dataSource;
@property(nonatomic, strong) NSArray* tweets;
//@property(nonatomic, strong) id didGainAccessObserver;
@property(nonatomic, strong) id didPostTweetObserver;
@property(nonatomic, strong) id foregroundNotificationObserver;
@property(nonatomic, strong) NSString* restoredIndexPathIdentifier;
@property(nonatomic, strong) BackgroundFetchCompletionBlock backgroundFetchCompletionBlock;
@property(nonatomic, strong) NSString* idOfMostRecentReadTweet;
@property(nonatomic) NSInteger numUnreadTweets;

@property(nonatomic) BOOL shouldLoadStreamMarker;
@property(nonatomic, strong) NSString* latestTweetMarkerTweetId;
@property(nonatomic, weak) NSOperation* runningLoadTweetMarkerOperation;
@property(nonatomic) BOOL tweetMarkerDidLoadSinceLastSession;

@end

@implementation TweetsController

- (NSString*)tweetsPersistenceIdentifier {
    return nil;
}

- (NSString*)stateRestorationIdentifier {
    return nil;
}

- (void)setNumUnreadTweets:(NSInteger)numUnreadTweets {
    
    _numUnreadTweets = numUnreadTweets;
    
    if (self.displayUnreadTweetIndicator) {
        
        if (numUnreadTweets > 0) {
            self.tabBarItem.badgeValue = @(numUnreadTweets).description;
        }
        else {
            self.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)dealloc {
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self.didGainAccessObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.didPostTweetObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.foregroundNotificationObserver];
    
    [self.runningLoadTweetMarkerOperation cancel];
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
    //self.tableView.restorationIdentifier = @"TableView";
    
    [self loadPersistedTimelinePosition];
    
    __weak typeof(self) weakSelf = self;
    
    /*self.didGainAccessObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kDidGainAccessToAccountNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
       
        if (!weakSelf.tweets.count) {
            [weakSelf loadNewTweets];
        }
    }];*/
    
    self.didPostTweetObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kUserDidPostTweetNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf.dataSource loadNewTweets];
    }];
    
    self.foregroundNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        if ([[weakSelf tweetsPersistenceIdentifier] isEqualToString:@"timeline"]) {
            weakSelf.shouldLoadStreamMarker = YES;
        }
        
        if (weakSelf.loadNewTweetsWhenGoingForeground) {
            [weakSelf.dataSource loadNewTweets];
        }
    }];
    
    self.shouldLoadStreamMarker = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([AFTwitterClient sharedClient].account) {
        
        if (!self.tweets.count) {
            
            [self willBeginRefreshing];
            [self.dataSource loadNewTweets];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self persistTimelinePosition];
}

#pragma mark -

- (void)tweetDataSource:(TweetsDataSource*)dataSource didLoadNewTweets:(NSArray*)tweets cached:(BOOL)cached {
    
    NSParameterAssert(tweets);
    
    [self didEndRefreshing];
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
                
                if (self.shouldLoadStreamMarker) {
                    
                    self.shouldLoadStreamMarker = NO;
                    [self loadTweetMarket];
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
            
            if (!self.displayUnreadTweetIndicator) {
                [NotificationView showInView:self.notificationViewPlaceholderView message:@"0 new tweets"];
            }
            
            if (self.backgroundFetchCompletionBlock) {
                
                self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNoData);
                self.backgroundFetchCompletionBlock = nil;
            }
            
            if (self.shouldLoadStreamMarker) {
                
                self.shouldLoadStreamMarker = NO;
                [self loadTweetMarket];
            }
            
            return;
        }
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
            self.numUnreadTweets += tweets.count;
            
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
            
            if (!self.displayUnreadTweetIndicator) {
                [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"%ld new tweets", (long)numOfNewTweets]];
            }
            
            if (self.backgroundFetchCompletionBlock) {
                
                self.backgroundFetchCompletionBlock(UIBackgroundFetchResultNewData);
                self.backgroundFetchCompletionBlock = nil;
            }
            
            [self.tableView flashScrollIndicators];
            
            if (self.shouldLoadStreamMarker) {
                
                self.shouldLoadStreamMarker = NO;
                [self loadTweetMarket];
            }
        });
    }
}

- (void)tweetDataSource:(TweetsDataSource*)dataSource didFailToLoadNewTweetsWithError:(NSError*)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [self.refreshControl endRefreshing];
    [self didEndRefreshing];
    
    if (self.backgroundFetchCompletionBlock) {
        
        self.backgroundFetchCompletionBlock(UIBackgroundFetchResultFailed);
        self.backgroundFetchCompletionBlock = nil;
    }
    else {
        
        [NotificationView showInView:self.notificationViewPlaceholderView message:@"Could not load new tweets" style:NotificationViewStyleError];
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

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFailToFillGap:(GapTweetEntity *)gap error:(NSError *)error {
    
    gap.loading = NO;
    
    [self.tableView reloadData];
    [NotificationView showInView:self.notificationViewPlaceholderView message:@"Could not load tweets" style:NotificationViewStyleError];
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
        
        if (self.tableView.numberOfSections > 1) {
            
            [self.tableView beginUpdates];
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:1];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        
        [NotificationView showInView:self.notificationViewPlaceholderView message:@"All tweets loaded"];
    }
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFailToLoadOldTweetsWithError:(NSError *)error {
    
    NSParameterAssert(error);
    
    [[LogService sharedInstance] logError:error];
    
    [NotificationView showInView:self.notificationViewPlaceholderView message:@"Could not load tweets" style:NotificationViewStyleError];
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didDeleteTweets:(NSArray *)tweets {
    
    NSMutableArray* indexPaths = [NSMutableArray new];
    
    NSInteger index = 0;
    for (TweetEntity* tweet in self.tweets) {
        
        for (TweetEntity* tweetToDelete in tweets) {
            
            if ([tweetToDelete.tweetId isEqualToString:tweet.tweetId]) {
                
                [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
        
        if (indexPaths.count == tweets.count) {
            break;
        }
        
        index++;
    }
    
    if (indexPaths.count) {
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        NSMutableArray* mutableTweets = [self.tweets mutableCopy];
        
        for (NSIndexPath* indexPath in indexPaths) {
            [mutableTweets removeObjectAtIndex:indexPath.row];
        }
        
        self.tweets = [mutableTweets copy];
    }
}

- (void)tweetDataSource:(TweetsDataSource *)dataSource didFailToDeleteTweetWithError:(NSError *)error {
    
    [NotificationView showInView:self.notificationViewPlaceholderView message:@"Could not delete tweet" style:NotificationViewStyleError];
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
        
        if (tweet.tweetId.longLongValue > self.idOfMostRecentReadTweet.longLongValue) {
            
            self.numUnreadTweets = indexPath.row;
            self.idOfMostRecentReadTweet = tweet.tweetId;
        }
        
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
    
    //NSLog(@"height for %@", indexPath);
    
    if (indexPath.section==0) {
        
        TweetEntity* tweet = self.tweets[indexPath.row];
        return [self heightForTweet:tweet];
    }
    else {
        
        return 44;
    }
}

/*- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        if (indexPath.row < 300) {
            
            TweetEntity* tweet = self.tweets[indexPath.row];
            return [self heightForTweet:tweet];
        }
        else {
            return UITableViewAutomaticDimension;
        }
    }
    else {
        
        return 44;
    }
}*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    for (UITableViewCell* testedCell in [self.tableView visibleCells]) {
        
        if ([testedCell isKindOfClass:[TweetCell class]]) {
            
            TweetCell* tweetCell = (TweetCell*)testedCell;
            [tweetCell cancelAccessViewAnimated];
        }
    }
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.runningLoadTweetMarkerOperation) {
        
        [self.runningLoadTweetMarkerOperation cancel];
        self.runningLoadTweetMarkerOperation = nil;
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

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.idOfMostRecentReadTweet forKey:@"idOfMostRecentReadTweet"];
    /*NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.idOfMostRecentReadTweet.length) {
        [userDefaults setValue:self.idOfMostRecentReadTweet forKey:kUserDefaultsKeyIdOfMostRecentTweet];
    }
    [userDefaults synchronize];*/
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.idOfMostRecentReadTweet = [coder decodeObjectForKey:@"idOfMostRecentReadTweet"];
    /*NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.idOfMostRecentReadTweet = [userDefaults objectForKey:kUserDefaultsKeyIdOfMostRecentTweet];*/
}

+ (UIViewController*)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    UIViewController* tweetsController = [[[self class] alloc] init];
    return tweetsController;
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

#pragma mark -

- (void)willBeginRefreshing {
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, -self.tableView.bounds.size.height);
    self.tableView.scrollEnabled = NO;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.tableView.bounds.size.width/2, 25 - self.tableView.bounds.size.height);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    self.activityIndicatorView = activityIndicator;
}

- (void)didEndRefreshing {
    
    [self.tableView reloadData];
    
    if (self.tableView.contentInset.top <= 64) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
        
        self.activityIndicatorView.center = CGPointMake(self.tableView.bounds.size.width/2, 25);
        self.activityIndicatorView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.tableView.scrollEnabled = YES;
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }];
}

#pragma mark -

- (void)persistTimelinePosition {
    
    if (!self.stateRestorationIdentifier.length) {
        return;
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* visibleRows = self.tableView.indexPathsForVisibleRows;
    for (NSIndexPath* indexPath in visibleRows) {
        
        TweetEntity* tweet = self.tweets[indexPath.row];
        if (![tweet isKindOfClass:[GapTweetEntity class]]) {
            
            NSString* username = [userDefaults objectForKey:kUserDefaultsKeyUsername];
            NSParameterAssert(username);
            [userDefaults setObject:tweet.tweetId forKey:[NSString stringWithFormat:@"%@-%@-%@", kUserDefaultsKeyTimelineRestorationIdentifier, self.stateRestorationIdentifier, username]];
            
            break;
        }
    }
    [userDefaults synchronize];

}

- (void)loadPersistedTimelinePosition {
    
    if (!self.stateRestorationIdentifier.length) {
        return;
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDefaults objectForKey:kUserDefaultsKeyUsername];
    NSParameterAssert(username);
    
    self.restoredIndexPathIdentifier = [userDefaults objectForKey:[NSString stringWithFormat:@"%@-%@-%@", kUserDefaultsKeyTimelineRestorationIdentifier, self.stateRestorationIdentifier, username]];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [super applicationDidEnterBackgroundNotification:notification];
    
    [self persistTimelinePosition];
    [self updateTweetMarker];
}

- (void)updateTweetMarker {
    
    if (![SettingsService sharedService].tweetMarkerEnabled) {
        return;
    }
    
    if ([self.tweetsPersistenceIdentifier isEqualToString:@"timeline"]) {
        
        if (!self.tweetMarkerDidLoadSinceLastSession) {
            return;
        }
        self.tweetMarkerDidLoadSinceLastSession = NO;
        
        NSArray* visibleRows = self.tableView.indexPathsForVisibleRows;
        for (NSIndexPath* indexPath in visibleRows) {
            
            TweetEntity* tweet = self.tweets[indexPath.row];
            if (![tweet isKindOfClass:[GapTweetEntity class]]) {
                
                if (!self.latestTweetMarkerTweetId || tweet.tweetId.longLongValue > self.latestTweetMarkerTweetId.longLongValue) {
                    
                    NSString* username = [UserService sharedInstance].username;
                    [TweetMarkerEntity notifyTweetMarkerUpdateWithTweetId:tweet.tweetId username:username completionHandler:^(NSError *error) {
                        
                        if (error) {
                            [[LogService sharedInstance] logError:error];
                        }
                        else {
                            NSLog(@"tweet market updated");
                        }
                    }];
                }
                
                break;
            }
        }
    }
}

- (void)loadTweetMarket {
    
    if (![SettingsService sharedService].tweetMarkerEnabled) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    NSString* username = [UserService sharedInstance].username;
    self.runningLoadTweetMarkerOperation = [TweetMarkerEntity requestTweetMarkerWithUsername:username completionHandler:^(TweetMarkerEntity *tweetMarker, NSError *error) {
       
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            return;
        }
        
        weakSelf.tweetMarkerDidLoadSinceLastSession = YES;
        
        if (!tweetMarker.tweetId) {
            return;
        }
        
        if (!weakSelf.latestTweetMarkerTweetId || tweetMarker.tweetId.longLongValue > self.latestTweetMarkerTweetId.longLongValue) {
            weakSelf.latestTweetMarkerTweetId = tweetMarker.tweetId;
        }
        
        NSLog(@"%@", tweetMarker);
        
        NSArray* visibleRows = self.tableView.indexPathsForVisibleRows;
        for (NSIndexPath* indexPath in visibleRows) {
            
            TweetEntity* tweet = self.tweets[indexPath.row];
            if (![tweet isKindOfClass:[GapTweetEntity class]]) {
                
                if (tweet.tweetId.longLongValue > weakSelf.latestTweetMarkerTweetId.longLongValue) {
                    return;
                }
            }
        }
        
        NSInteger row = 0;
        for (TweetEntity* tweet in weakSelf.tweets) {
            
            if ([tweet.tweetId isEqualToString:tweetMarker.tweetId]) {
                
                NSLog(@"market tweet found");
                
                NSLog(@"%@", tweet.text);
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                break;
            }
            
            row++;
        }
    }];
}

@end
