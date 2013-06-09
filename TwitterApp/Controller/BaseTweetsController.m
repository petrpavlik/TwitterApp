//
//  BaseTweetsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseTweetsController.h"
#import "GapTweetEntity.h"
#import "LoadingCell.h"
#import "LoadMoreCell.h"
#import <PocketAPI.h>
#import "NotificationView.h"
#import "NSString+TwitterApp.h"
#import "TimelineController.h"
#import "TweetCell.h"
#import "TweetEntity.h"
#import "UIActionSheet+TwitterApp.h"
#import "UIImage+TwitterApp.h"
#import "UserListController.h"
#import "WebController.h"

@interface BaseTweetsController () <UIActionSheetDelegate>

@property(nonatomic, strong) NSTimer* updateTweetAgeTimer;

@end

@implementation BaseTweetsController

- (void)dealloc {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerClass:[LoadMoreCell class] forCellReuseIdentifier:@"LoadMoreCell"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tableView.separatorColor = [UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1];
    
    self.updateTweetAgeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTweetAge) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateTweetAge];
    self.updateTweetAgeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTweetAge) userInfo:nil repeats:YES];
    [self.updateTweetAgeTimer fire];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.updateTweetAgeTimer invalidate];
    self.updateTweetAgeTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGFloat)heightForTweet:(TweetEntity*)tweet {
    
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

- (UITableViewCell*)cellForTweet:(TweetEntity *)tweet atIndexPath:(NSIndexPath*)indexPath {
    
    NSParameterAssert(tweet);
    
    if ([tweet isKindOfClass:[GapTweetEntity class]]) {
        
        static NSString *CellIdentifier = @"LoadMoreCell";
        
        LoadMoreCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
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
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.delegate = self;
        
        TweetEntity* retweet = nil;
        
        if (tweet.retweetedStatus) {
            retweet = tweet;
            tweet = tweet.retweetedStatus;
        }
        
        cell.nameLabel.text = tweet.user.name;
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
        
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[tweet.user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
            
            return [image imageWithRoundCornersWithRadius:5 size:CGSizeMake(48, 48)];
        }];
        
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
            
            [cell.mediaImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:medium", media[0][@"media_url"]]] placeholderImage:nil imageProcessingBlock:^UIImage *(UIImage *image) {
                
                UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                return image;
            }];
            cell.mediaImageView.hidden = NO;
        }
        
        for (NSDictionary* item in hashtags) {
            
            NSString* hashtag = [NSString stringWithFormat:@"#%@", item[@"text"]];
            [cell addHashtag:hashtag atRange:[expandedTweet rangeOfString:hashtag options:NSCaseInsensitiveSearch]];
        }
        
        for (NSDictionary* item in mentions) {
            
            NSString* mention = [NSString stringWithFormat:@"@%@", item[@"screen_name"]];
            [cell addMention:mention atRange:[expandedTweet rangeOfString:mention options:NSCaseInsensitiveSearch]];
        }
        
        return cell;
    }
}

#pragma mark -


#pragma mark -

- (void)tweetCell:(TweetCell *)cell didSelectURL:(NSURL *)url {
    
    [WebController presentWithUrl:url viewController:self];
}

- (void)tweetCell:(TweetCell *)cell didLongPressURL:(NSURL *)url {
    
    __weak typeof(self) weakSelf = self;
    
    [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
        
        if (!weakSelf) {
            
            if (error) {
                [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Link saved" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
            
            return;
        }
        
        if (error) {
            
            [NotificationView showInView:weakSelf.view message:error.localizedDescription];
        } else {
            
            [NotificationView showInView:weakSelf.view message:@"Link saved to Pocket"];
        }
    }];
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
    
}

- (void)tweetCellDidRequestLeftAction:(TweetCell *)cell {
    
}

- (void)tweetCellDidSelectAvatarImage:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    
    NSParameterAssert(tweet);
    
    TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    
    if (tweet.retweetedStatus) {
        timelineController.screenName = tweet.retweetedStatus.user.screenName;
    }
    else {
        timelineController.screenName = tweet.user.screenName;
    }
    
    [self.navigationController pushViewController:timelineController animated:YES];
}

- (void)tweetCellDidLongPress:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Retweets", nil];
    
    actionSheet.userInfo = @{@"tweet": tweet};
    [actionSheet showInView:self.view];
}

#pragma mark -

- (TweetEntity*)tweetForIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateTweetAge {
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        if ([cell isKindOfClass:[TweetCell class]]) {
            
            NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
            TweetEntity* tweet = [self tweetForIndexPath:indexPath];
            NSParameterAssert(tweet);
            
            TweetCell* tweetCell = (TweetCell*)cell;
            tweetCell.tweetAgeLabel.text = [self ageAsStringForDate:tweet.createdAt];
        }
    }
}

#pragma mark -

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification {
    
    [self.updateTweetAgeTimer invalidate];
    self.updateTweetAgeTimer = nil;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillEnterForegroundNotification:(NSNotification*)notification {
    
    [self updateTweetAge];
    self.updateTweetAgeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTweetAge) userInfo:nil repeats:YES];
    [self.updateTweetAgeTimer fire];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"%@", actionSheet.userInfo);
    
    UserListController* userListController = [[UserListController alloc] initWithStyle:UITableViewStylePlain];
    TweetEntity* tweet = actionSheet.userInfo[@"tweet"];
    
    NSParameterAssert(tweet);
    userListController.tweetIdForRetweets = tweet.tweetId;
    
    [self.navigationController pushViewController:userListController animated:YES];
}

@end
