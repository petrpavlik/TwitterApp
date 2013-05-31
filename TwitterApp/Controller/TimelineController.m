//
//  TimelineController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "AFTwitterClient.h"
#import "GapTweetEntity.h"
#import "LoadingCell.h"
#import "LoadMoreCell.h"
#import <MBProgressHUD.h>
#import "NSString+TwitterApp.h"
#import "TimelineController.h"
#import "TweetCell.h"
#import "TweetEntity.h"
#import "TweetController.h"
#import "UserTitleView.h"
#import "WebController.h"

@interface TimelineController () <TweetCellDelegate>

@property(nonatomic, weak) NSOperation* runningOlderTweetsOperation;
@property(nonatomic, weak) NSOperation* runningNewTweetsOperation;
@property(nonatomic, strong) NSArray* tweets;
@property(nonatomic, strong) NSTimer* updateTweetAgeTimer;

@end

@implementation TimelineController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSAssert(!(self.searchQuery && self.screenName), @"cannot set both searchQuery and screenName");
    
    self.title = @"Timeline";
    
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerClass:[LoadMoreCell class] forCellReuseIdentifier:@"LoadMoreCell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestNewTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTweet)];
    
    self.searchQuery = @"ass";
    
    if (self.searchQuery.length) {
        self.title = self.searchQuery;
    }
    else if (self.screenName.length) {
        self.title = [NSString stringWithFormat:@"@%@", self.screenName];
    }
    else {
        
        UserTitleView* userTitleView = [[UserTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        
        NSDictionary* attributes = self.navigationController.navigationBar.titleTextAttributes;
        attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:18], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        
        NSAttributedString* nameAttrString = [[NSAttributedString alloc] initWithString:@"@ptrpavlik" attributes:attributes];
        userTitleView.nameLabel.attributedText = nameAttrString;
        
        [userTitleView.avatarImageView setImageWithURL:[NSURL URLWithString:@"https://si0.twimg.com/profile_images/3126864086/30bb0202747f2a78d08dc147468b170b_normal.jpeg"] placeholderImage:nil];
        self.navigationItem.titleView = userTitleView;
    }
    
    self.updateTweetAgeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTweetAge) userInfo:nil repeats:YES];
    
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateTweetAge];
    [self.updateTweetAgeTimer fire];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.updateTweetAgeTimer invalidate];
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
        
        if ([tweet isKindOfClass:[GapTweetEntity class]]) {
            
            static NSString *CellIdentifier = @"LoadMoreCell";
            
            LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            GapTweetEntity* gapTweet = (GapTweetEntity*)tweet;
            if (gapTweet.loading.boolValue) {
                cell.loading = YES;
            }
            else {
                cell.loading = NO;
            }
            
            return cell;
        }
        else {
            
            static NSString *CellIdentifier = @"TweetCell";
            TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            cell.delegate = self;
            
            TweetEntity* retweet = nil;
            
            if (tweet.retweetedStatus) {
                retweet = tweet;
                tweet = tweet.retweetedStatus;
            }
            
            cell.nameLabel.text = tweet.user.name;
            cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[tweet.user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil];
            cell.tweetAgeLabel.text = [self ageAsStringForDate:tweet.createdAt];
            
            if (retweet) {
                cell.retweetedLabel.text = [NSString stringWithFormat:@"Retweeted by %@", retweet.user.name];
            }
            
            cell.mediaImageView.hidden = YES;
            
            NSString* expandedTweet = [tweet.text stringByStrippingHTMLTags];
            
            NSArray* urls = tweet.entities[@"urls"];
            NSArray* media = tweet.entities[@"media"];
            NSArray* hashtags = tweet.entities[@"hashtags"];
            NSArray* mentions = tweet.entities[@"user_mentions"];
            
            for (NSDictionary* url in urls) {
                expandedTweet = [expandedTweet stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
            }
            
            for (NSDictionary* url in media) {
                expandedTweet = [expandedTweet stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
            }
            
            cell.tweetTextLabel.text = expandedTweet;
            
            for (NSDictionary* url in urls) {
                
                NSURL* expandedUrl = [NSURL URLWithString:[url[@"expanded_url"] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
                if (expandedUrl) {
                    [cell addURL:expandedUrl atRange:[expandedTweet rangeOfString:url[@"display_url"]]];
                }
                else {
                    //TODO: should not happen, log an error
                    NSLog(@"could not convert '%@' to NSURL", url[@"expanded_url"]);
                }
            }
            
            for (NSDictionary* url in media) {
                
                [cell addURL:[NSURL URLWithString:url[@"media_url"]] atRange:[expandedTweet rangeOfString:url[@"display_url"]]];
            }
            
            if (media.count) {
                
                [cell.mediaImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:medium", media[0][@"media_url"]]] placeholderImage:nil];
                cell.mediaImageView.hidden = NO;
            }
            
            for (NSDictionary* item in hashtags) {
                
                NSString* hashtag = [NSString stringWithFormat:@"#%@", item[@"text"]];
                [cell addHashtag:hashtag atRange:[expandedTweet rangeOfString:hashtag]];
            }
            
            for (NSDictionary* item in mentions) {
                
                NSString* mention = [NSString stringWithFormat:@"@%@", item[@"screen_name"]];
                [cell addMention:mention atRange:[expandedTweet rangeOfString:mention]];
            }
            
            return cell;
        }
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
        
        if ([tweet isKindOfClass:[GapTweetEntity class]]) {
            return 44;
        }
        else {
            
            TweetEntity* retweet = nil;
            
            if (tweet.retweetedStatus) {
                
                retweet = tweet;
                tweet = tweet.retweetedStatus;
            }
            
            NSString* tweetText = [tweet.text stringByStrippingHTMLTags];
            
            NSArray* urls = tweet.entities[@"urls"];
            for (NSDictionary* url in urls) {
                
                tweetText = [tweetText stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
            }
            
            NSArray* media = tweet.entities[@"media"];
            for (NSDictionary* url in media) {
                
                tweetText = [tweetText stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
            }
            
            CGFloat mediaHeight = 0;
            
            if (media.count) {
                
                mediaHeight = [media[0][@"sizes"][@"medium"][@"h"] integerValue]/2 + 10;
            }
            
            CGFloat retweetInformationHeight = 0;
            if (retweet) {
                retweetInformationHeight = 15;
            }
            
            return [TweetCell requiredHeightForTweetText:tweetText] + mediaHeight + retweetInformationHeight;
        }
    }
    else {
        
        return 44;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        
        [TweetEntity requestSearchRepliesWithTweetId:tweet.tweetId screenName:tweet.user.screenName completionBlock:^(NSArray *tweets, NSError *error) {
            
            for (TweetEntity* reply in tweets) {
                NSLog(@"%@", reply.text);
            }
        }];
    }
}


#pragma mark -

- (void)requestData {
    
    [self.refreshControl beginRefreshing];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0) {
                
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                //NSLog(@"%@", twitterAccount);
                
                [AFTwitterClient sharedClient].account = twitterAccount;
                
                //[TweetEntity testDirectMessages];
                
                void (^completionBlock)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
                    
                    //NSLog(@"%@", tweets);
                    self.tweets = tweets;
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
            
        } else {
            
            NSLog(@"No access granted %@", error);
        }
    }];
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
        
        self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
        
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
        
        for (TweetEntity* potentialGapTweet in self.tweets) {
            
            if ([potentialGapTweet isKindOfClass:[GapTweetEntity class]]) {
                
                NSMutableArray* mutableTweets = [self.tweets mutableCopy];
                NSInteger index = [mutableTweets indexOfObject:potentialGapTweet];
                
                [mutableTweets removeObjectAtIndex:index];
                
                for (TweetEntity* tweetToAdd in tweets) {
                    
                    if (tweetToAdd == tweets.lastObject) {
                        
                        if ([tweetToAdd.tweetId isEqualToString:[mutableTweets[index] tweetId]]) {
                            
                            //no gap
                            [mutableTweets insertObject:tweetToAdd atIndex:index];
                            index++;
                        }
                        else {
                            
                            [mutableTweets insertObject:[GapTweetEntity new] atIndex:index];
                            index++;
                        }
                    }
                    else {
                        
                        [mutableTweets insertObject:tweetToAdd atIndex:index];
                        index++;
                    }
                }
                
                self.tweets = mutableTweets;
            }
        }
        
        [self.tableView reloadData];
        
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

- (void)tweetCell:(TweetCell *)cell didSelectURL:(NSURL *)url {
    
    [WebController presentWithUrl:url viewController:self];
}

- (void)tweetCell:(TweetCell *)cell didSelectHashtag:(NSString *)hashstag {
    
    NSLog(@"selected hashtag %@", hashstag);
    
    TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    timelineController.searchQuery = hashstag;
    
    [self.navigationController pushViewController:timelineController animated:YES];
}

- (void)tweetCell:(TweetCell *)cell didSelectMention:(NSString *)mention {
    
    NSLog(@"selected mention %@", mention);
    
    TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    timelineController.screenName = [mention stringByReplacingOccurrencesOfString:@"@" withString:@""];
    
    [self.navigationController pushViewController:timelineController animated:YES];
}


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

- (void)tweetCellDidSelectAvatarImage:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    
    if (tweet.retweetedStatus) {
        timelineController.screenName = tweet.retweetedStatus.user.screenName;
    }
    else {
        timelineController.screenName = tweet.user.screenName;
    }
    
    [self.navigationController pushViewController:timelineController animated:YES];
}

#pragma mark -

- (NSString*)ageAsStringForDate:(NSDate*)date {
    
    NSParameterAssert(date);
 
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *difference = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date toDate:[NSDate date] options:0];
    
    if (difference.year) {
        return [NSString stringWithFormat:@"%dy", difference.year];
    }
    else if (difference.month) {
        return [NSString stringWithFormat:@"%dm", difference.month];
    }
    else if (difference.day) {
        return [NSString stringWithFormat:@"%dd", difference.day];
    }
    else if (difference.hour) {
        return [NSString stringWithFormat:@"%dh", difference.hour];
    }
    else if (difference.minute) {
        return [NSString stringWithFormat:@"%dm", difference.minute];
    }
    else {
        return [NSString stringWithFormat:@"%ds", difference.second];
    }
}

#pragma mark -

- (void)composeTweet {
    
    [TweetController presentInViewController:self];
}

- (void)updateTweetAge {
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        if ([cell isKindOfClass:[TweetCell class]]) {
            
            NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
            TweetEntity* tweet = self.tweets[indexPath.row];
            
            TweetCell* tweetCell = (TweetCell*)cell;
            tweetCell.tweetAgeLabel.text = [self ageAsStringForDate:tweet.createdAt];
        }
    }
}

@end
