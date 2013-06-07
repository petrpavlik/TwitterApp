//
//  TimelineController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "BasementController.h"
#import "AFTwitterClient.h"
#import <ECSlidingViewController.h>
#import "GapTweetEntity.h"
#import "LoadingCell.h"
#import "LoadMoreCell.h"
#import <MBProgressHUD.h>
#import "NSString+TwitterApp.h"
#import "TimelineController.h"
#import "TimelineDocument.h"
#import "TweetCell.h"
#import "TweetDetailController.h"
#import "TweetEntity.h"
#import "TweetController.h"
#import "UserListController.h"
#import "UserTitleView.h"
#import "WebController.h"

@interface TimelineController () <TweetCellDelegate, TimelineDocumentDelegate>

@property(nonatomic, weak) NSOperation* runningOlderTweetsOperation;
@property(nonatomic, weak) NSOperation* runningNewTweetsOperation;
@property(nonatomic, strong) NSArray* tweets;
@property(nonatomic, strong) TimelineDocument* timelineDocument;

@end

@implementation TimelineController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSAssert(!(self.searchQuery && self.screenName), @"cannot set both searchQuery and screenName");
    
    self.title = @"Timeline";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestNewTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.refreshControl.tintColor = [UIColor blackColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTweet)];
    
    if (self.navigationController.viewControllers[0] == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showBasement)];
    }
    
    //self.searchQuery = @"ass";
    
    if (self.searchQuery.length) {
        self.title = self.searchQuery;
    }
    else if (self.screenName.length) {
        self.title = [NSString stringWithFormat:@"@%@", self.screenName];
    }
    else {
        
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        AbstractSkin* skin = appDelegate.skin;
        
        UserTitleView* userTitleView = [[UserTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        
        NSDictionary* attributes = self.navigationController.navigationBar.titleTextAttributes;
        attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[skin fontOfSize:18], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        
        NSAttributedString* nameAttrString = [[NSAttributedString alloc] initWithString:@"@ptrpavlik" attributes:attributes];
        userTitleView.nameLabel.attributedText = nameAttrString;
        
        [userTitleView.avatarImageView setImageWithURL:[NSURL URLWithString:@"https://si0.twimg.com/profile_images/3126864086/30bb0202747f2a78d08dc147468b170b_normal.jpeg"] placeholderImage:nil];
        self.navigationItem.titleView = userTitleView;
    }
    
    [self validateTwitterAccountWithCompletionBlock:^(NSError *error) {
        
        if (!self.searchQuery.length && !self.screenName.length) {
            
            /////////////
            NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [dirPaths objectAtIndex:0];
            NSString *dataFile = [docsDir stringByAppendingPathComponent:@"dummyTimeline"];
            NSURL* documentUrl = [NSURL fileURLWithPath:dataFile];
            
            self.timelineDocument = [[TimelineDocument alloc] initWithFileURL:documentUrl];
            self.timelineDocument.delegate = self;
            
            NSFileManager *filemgr = [NSFileManager defaultManager];
            
            if ([filemgr fileExistsAtPath: dataFile]) {
                
                [self.timelineDocument openWithCompletionHandler:^(BOOL success) {
                    NSLog(@"document open %d", success);
                }];
                
            } else {
                
                [self.timelineDocument saveToURL:documentUrl forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                    NSLog(@"document created %d", success);
                }];
            }
            
            /////////////
        }
        else {
            [self requestData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[BasementController class]]) {
        self.slidingViewController.underLeftViewController  = [[BasementController alloc] initWithStyle:UITableViewStylePlain];
    }
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
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
        
        TweetEntity* oldestTweet = self.tweets.lastObject;
        [self requestTweetsWithMaxId:oldestTweet.tweetId];
        
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
    
    UserListController* userListController = [[UserListController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:userListController animated:YES];
    
    return;
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    if ([tweet isKindOfClass:[GapTweetEntity class]]) {
        
        GapTweetEntity* gapTweet = (GapTweetEntity*)tweet;
        gapTweet.loading = @(YES);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        [self requestTweetsSinceId:[self.tweets[indexPath.row+1] tweetId] withMaxId:[self.tweets[indexPath.row-1] tweetId]];
    }
    else {
        
        TweetDetailController* tweetDetailController = [[TweetDetailController alloc] initWithStyle:UITableViewStylePlain];
        tweetDetailController.tweet = tweet;
        
        [self.navigationController pushViewController:tweetDetailController animated:YES];
    }
}


#pragma mark -

- (void)requestData {
    
    [self.refreshControl beginRefreshing];
    
    void (^completionBlock)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
        
        if (error) {
            
            [self.refreshControl endRefreshing];
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = error.localizedDescription;
            [hud hide:YES afterDelay:3];
            return;
        }
        
        //NSLog(@"%@", tweets);
        self.tweets = tweets;
        
        if (self.timelineDocument) {
            [self.timelineDocument persistTimeline:self.tweets];
        }
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"%d new tweets", tweets.count];
        [hud hide:YES afterDelay:3];
    };
    
    if (self.searchQuery.length) {
        [TweetEntity requestSearchWithQuery:self.searchQuery maxId:nil sinceId:nil completionBlock:completionBlock];
    }
    else if (self.screenName.length) {
        [TweetEntity requestUserTimelineWithScreenName:self.screenName maxId:nil sinceId:nil completionBlock:completionBlock];
    }
    else {
        [TweetEntity requestHomeTimelineWithMaxId:nil sinceId:nil completionBlock:completionBlock];
    }
}

- (void)requestNewTweets {
    
    TweetEntity* mostRecentTweet = self.tweets[0];
    [self requestTweetsSinceId:mostRecentTweet.tweetId];
}

- (void)requestTweetsSinceId:(NSString*)sinceId {
    
    NSParameterAssert(sinceId);
    
    if (self.runningNewTweetsOperation) {
        return;
    }
    
    void (^completionBlock)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
        
        self.tableView.userInteractionEnabled = NO;
        
        [self.refreshControl endRefreshing];
        
        if (error) {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = error.localizedDescription;
            [hud hide:YES afterDelay:3];
            return;
        }
        
        //wait for the refresh control to hide
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSMutableArray* mutableNewTweets = [tweets mutableCopy];
            
            if ([[mutableNewTweets.lastObject tweetId] isEqualToString:[self.tweets[0] tweetId]]) {
                
                //no gap detected
                NSLog(@"no gap detected");
                [mutableNewTweets removeLastObject];
            }
            else {
                
                //gap detected
                NSLog(@"gap detected");
                
                //[[[UIAlertView alloc] initWithTitle:nil message:@"gap detected" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                
                [mutableNewTweets removeLastObject];
                [mutableNewTweets addObject:[GapTweetEntity new]];
            }
            
            self.tweets = [mutableNewTweets arrayByAddingObjectsFromArray:self.tweets];
            
            if (self.timelineDocument) {
                [self.timelineDocument persistTimeline:self.tweets];
            }
            
            CGFloat contentOffsetY = self.tableView.contentOffset.y;
            
            [self.tableView reloadData];
            
            for (TweetEntity* tweet in mutableNewTweets) {
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tweets indexOfObject:tweet] inSection:0];
                contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            }
            
            self.tableView.contentOffset = CGPointMake(0, contentOffsetY);
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = [NSString stringWithFormat:@"%d new tweets", mutableNewTweets.count];
            [hud hide:YES afterDelay:3];
            
            self.tableView.userInteractionEnabled = YES;
        });
    };
    
    //we want out most recent tweet to be eventually returned again in order to detect a gap
    long long sinceIdLong = [sinceId longLongValue];
    sinceIdLong -= 1;
    sinceId = @(sinceIdLong).description;
    
    if (self.searchQuery.length) {
        [TweetEntity requestSearchWithQuery:self.searchQuery maxId:nil sinceId:sinceId completionBlock:completionBlock];
    }
    else if (self.screenName.length) {
        [TweetEntity requestUserTimelineWithScreenName:self.screenName maxId:nil sinceId:sinceId completionBlock:completionBlock];
    }
    else {
        self.runningNewTweetsOperation = [TweetEntity requestHomeTimelineWithMaxId:nil sinceId:sinceId completionBlock:completionBlock];
    }
}

- (void)requestTweetsWithMaxId:(NSString*)maxId {
    
    NSParameterAssert(maxId);
    
    //we dodn't really want the maxId tweet to be returned again
    long long maxIdLong = [maxId longLongValue];
    maxIdLong -= 1;
    maxId = @(maxIdLong).description;
    
    if (self.runningOlderTweetsOperation) {
        return;
    }
    
    void (^completionBlock)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
        
        if (error) {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = error.localizedDescription;
            [hud hide:YES afterDelay:3];
            return;
        }
        
        self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
        
        if (self.timelineDocument) {
            [self.timelineDocument persistTimeline:self.tweets];
        }
        
        [self.tableView beginUpdates];
        
        NSMutableArray* indexPaths = [[NSMutableArray alloc] initWithCapacity:tweets.count];
        for (NSInteger i=0; i<tweets.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.tweets.count-tweets.count+i inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"%d new tweets", tweets.count];
        [hud hide:YES afterDelay:3];
    };
    
    if (self.searchQuery.length) {
        [TweetEntity requestSearchWithQuery:self.searchQuery maxId:maxId sinceId:nil completionBlock:completionBlock];
    }
    else if (self.screenName.length) {
        [TweetEntity requestUserTimelineWithScreenName:self.screenName maxId:maxId sinceId:nil completionBlock:completionBlock];
    }
    else {
        self.runningNewTweetsOperation = [TweetEntity requestHomeTimelineWithMaxId:maxId sinceId:nil completionBlock:completionBlock];
    }    
}

- (void)requestTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId {
    
    NSParameterAssert(sinceId);
    NSParameterAssert(maxId);
    
    long long maxIdLong = [maxId longLongValue];
    maxIdLong -= 1;
    maxId = @(maxIdLong).description;
    
    long long sinceIdLong = [sinceId longLongValue];
    sinceIdLong -= 1;
    sinceId = @(sinceIdLong).description;
    
    void (^completionBlock)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
        
        if (error) {
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = error.localizedDescription;
            [hud hide:YES afterDelay:3];
            return;
        }

        
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
        
        for (TweetEntity* potentialGapTweet in self.tweets) {
            
            if ([potentialGapTweet isKindOfClass:[GapTweetEntity class]]) {
                
                NSMutableArray* mutableTweets = [self.tweets mutableCopy];
                NSInteger index = [mutableTweets indexOfObject:potentialGapTweet];
                
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                contentOffsetY -= [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                [mutableTweets removeObjectAtIndex:index];
                
                for (TweetEntity* tweetToAdd in tweets) {
                    
                    if (tweetToAdd == tweets.lastObject) {
                        
                        if ([tweetToAdd.tweetId isEqualToString:[mutableTweets[index] tweetId]]) {
                            
                            //no gap
                            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                            [mutableTweets insertObject:tweetToAdd atIndex:index];
                            index++;
                        }
                        else {
                            
                            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                            [mutableTweets insertObject:[GapTweetEntity new] atIndex:index];
                            index++;
                        }
                    }
                    else {
                        
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        contentOffsetY += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                        [mutableTweets insertObject:tweetToAdd atIndex:index];
                        index++;
                    }
                }
                
                self.tweets = mutableTweets;
                
                if (self.timelineDocument) {
                    [self.timelineDocument persistTimeline:self.tweets];
                }
            }
            
            break;
        }
        
        [self.tableView reloadData];
        
        //self.tableView.contentOffset = CGPointMake(0, contentOffsetY);
        
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"%d new tweets", tweets.count];
        [hud hide:YES afterDelay:3];
    };
    
    if (self.searchQuery.length) {
        [TweetEntity requestSearchWithQuery:self.searchQuery maxId:maxId sinceId:sinceId completionBlock:completionBlock];
    }
    else if (self.screenName.length) {
        [TweetEntity requestUserTimelineWithScreenName:self.screenName maxId:maxId sinceId:sinceId completionBlock:completionBlock];
    }
    else {
        self.runningNewTweetsOperation = [TweetEntity requestHomeTimelineWithMaxId:maxId sinceId:sinceId completionBlock:completionBlock];
    }
}


#pragma mark -

- (void)tweetCellDidRequestRightAction:(TweetCell *)cell {
    
    NSLog(@"about to retweet");
    //return; //!!!!!
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    [tweet requestRetweetWithCompletionBlock:^(TweetEntity *updatedTweet, NSError *error) {
       
        //NSLog(@"%@", updatedTweet);
        if ([self.tweets isKindOfClass:[NSMutableArray class]]) {
            
            NSMutableArray *mutableTweets = (NSMutableArray*)self.tweets;
            mutableTweets[indexPath.row] = updatedTweet;
        }
        else {
            
            NSMutableArray *mutableTweets = [self.tweets mutableCopy];
            mutableTweets[indexPath.row] = updatedTweet;
            self.tweets = mutableTweets;
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
}

- (void)tweetCellDidRequestLeftAction:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    [TweetController presentAsReplyToTweet:tweet inViewController:self];
}

#pragma mark -

- (void)timelineDocumentDidLoadPersistedTimeline:(NSArray *)tweets {
    
    if (tweets.count) {
        
        self.tweets = tweets;
        [self.tableView reloadData];
    }
    else {
        [self requestData];
    }
}

#pragma mark -

- (void)composeTweet {
    
    [TweetController presentInViewController:self];
}

- (void)showBasement {
    
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark -

- (void)validateTwitterAccountWithCompletionBlock:(void (^)(NSError* error))block {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0) {
                
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                //iOS 6 bug fix
                ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                twitterAccount.accountType = accountTypeTwitter;
                
                [AFTwitterClient sharedClient].account = twitterAccount;
                
                block(nil);
            }
            
        } else {
            
            NSLog(@"No access granted %@", error);
            block(error);
        }
    }];

}

#pragma mark -

- (TweetEntity*)tweetForIndexPath:(NSIndexPath *)indexPath {
    return self.tweets[indexPath.row];
}


@end
