//
//  BaseTweetsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFNetworkActivityIndicatorManager.h>
#import "BaseTweetsController.h"
#import "GapTweetEntity.h"
#import "LoadingCell.h"
#import "LoadMoreCell.h"
#import "MHFacebookImageViewer.h"
#import "NotificationView.h"
#import "NSString+TwitterApp.h"
#import <PocketAPI.h>
#import "ProfileController.h"
#import "RetweetersController.h"
#import "TimelineController.h"
#import "TweetCell.h"
#import "TweetController.h"
#import "TweetDetailCell.h"
#import "TweetEntity.h"
#import "UIActionSheet+TwitterApp.h"
#import "UIImage+TwitterApp.h"
#import "WebController.h"

@interface BaseTweetsController () <UIActionSheetDelegate>

@property(nonatomic, strong) NSTimer* updateTweetAgeTimer;
@property(nonatomic, strong) NSMutableDictionary* savedImagesForVisibleCells;

@end

@implementation BaseTweetsController

- (NSMutableDictionary*)savedImagesForVisibleCells {
    
    if (!_savedImagesForVisibleCells) {
        _savedImagesForVisibleCells = [NSMutableDictionary new];
    }
    
    return _savedImagesForVisibleCells;
}

- (void)dealloc {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerClass:[TweetDetailCell class] forCellReuseIdentifier:@"TweetDetailCell"];
    [self.tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    [self.tableView registerClass:[LoadMoreCell class] forCellReuseIdentifier:@"LoadMoreCell"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteTweetNotification:) name:kTweetDeletedNotification object:Nil];
    
    //self.tableView.separatorColor = [UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
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

- (CGFloat)heightForTweetDetail:(TweetEntity*)tweet {
    
    return 300;
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
        
        if (NO && self.savedImagesForVisibleCells[tweet.tweetId]) {
            
            cell.avatarImageView.image = self.savedImagesForVisibleCells[tweet.tweetId];
            [self.savedImagesForVisibleCells removeObjectForKey:tweet.tweetId];
        }
        else {
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[tweet.user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) { 
                return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
            }];
        }
        
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
            [cell.mediaImageView  setupImageViewer];
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

- (UITableViewCell*)cellForTweetDetail:(TweetEntity *)tweet atIndexPath:(NSIndexPath*)indexPath {
    
    static NSString *CellIdentifier = @"TweetDetailCell";
    TweetDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.nameLabel.text = tweet.user.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[tweet.user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
        
        return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
    }];
    
    cell.createdWithLabel.text = [NSString stringWithFormat:@"via %@", [tweet.source stringByStrippingHTMLTags]];
    
    cell.tweetTextLabel.text = tweet.text;
    
    if (tweet.place[@"name"]) {
        cell.locationLabel.text = [NSString stringWithFormat:@"from %@", tweet.place[@"name"]];
    }
    
    return cell;
}

#pragma mark -


#pragma mark -

- (void)tweetCell:(TweetCell *)cell didSelectURL:(NSURL *)url {
    
    [WebController presentWithUrl:url viewController:self];
}

- (void)tweetCell:(TweetCell *)cell didLongPressURL:(NSURL *)url {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Pocket", @"Open in Safari", nil];
    
    actionSheet.userInfo = @{@"url": url};
    [actionSheet showInView:self.view];
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


- (void)tweetCellDidRequestReply:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    if (!indexPath) {
        return;
    }
    
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    [TweetController presentAsReplyToTweet:tweet inViewController:self];
}

- (void)tweetCellDidRequestRetweet:(TweetCell *)cell {
    //handled in a subclass
}

- (void)tweetCellDidRequestFavorite:(TweetCell *)cell {
    //handled in a subclass
}

- (void)tweetCellDidRequestOtherAction:(TweetCell *)cell {
    
}

- (void)tweetCellDidSelectAvatarImage:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    
    NSParameterAssert(tweet);
    
    /*TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
    
    if (tweet.retweetedStatus) {
        timelineController.screenName = tweet.retweetedStatus.user.screenName;
    }
    else {
        timelineController.screenName = tweet.user.screenName;
    }
    
    [self.navigationController pushViewController:timelineController animated:YES];*/
    
    ProfileController* profileController = [[ProfileController alloc] initWithStyle:UITableViewStylePlain];
    
    if (tweet.retweetedStatus) {
        profileController.user = tweet.retweetedStatus.user;
    }
    else {
        profileController.user = tweet.user;
    }
    
    [self.navigationController pushViewController:profileController animated:YES];
}

- (void)tweetCellDidLongPress:(TweetCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TweetEntity* tweet = [self tweetForIndexPath:indexPath];
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    NSString* destructiveButtonTitle = nil;
    UserEntity* currentUser = [UserEntity currentUser];
    
    if (currentUser && [tweet.user.userId isEqualToString:currentUser.userId]) {
        destructiveButtonTitle = @"Delete";
    }
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:@"Show Retweets", nil];
    
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

- (void)didDeleteTweetNotification:(NSNotification*)notification {
    
    TweetEntity* tweet = notification.userInfo[@"tweet"];
    NSParameterAssert(tweet);
    
    [self didDeleteTweet:tweet];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.userInfo[@"tweet"]) {
        
        TweetEntity* tweet = actionSheet.userInfo[@"tweet"];
        NSParameterAssert(tweet);
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            
            [TweetEntity requestDeletionOfTweetWithId:tweet.tweetId completionBlock:^(NSError *error) {
                
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:Nil message:error.localizedRecoverySuggestion delegate:Nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTweetDeletedNotification object:Nil userInfo:@{@"tweet": tweet}];
            }];
        }
        else if (buttonIndex==0) {
         
            RetweetersController* retweetersController = [[RetweetersController alloc] initWithStyle:UITableViewStylePlain];
            
            retweetersController.tweetId = tweet.tweetId;
            [self.navigationController pushViewController:retweetersController animated:YES];
        }
    }
    else if (actionSheet.userInfo[@"url"]) {
        
        if (buttonIndex==0) {
            
            __weak typeof(self) weakSelf = self;
            
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            
            [[PocketAPI sharedAPI] saveURL:actionSheet.userInfo[@"url"] handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
            
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                
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
        else if (buttonIndex==1) {
            
            [[UIApplication sharedApplication] openURL:actionSheet.userInfo[@"url"]];
        }
    }
}

#pragma mark -

- (void)saveImagesForVisibleCells {
    
    return;
    
    NSMutableDictionary* savedImagesForVisibleRows = [NSMutableDictionary new];
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        if ([cell isKindOfClass:[TweetCell class]]) {
            
            TweetCell* tweetCell = (TweetCell*)cell;
            NSIndexPath* indexPath = [self.tableView indexPathForCell:tweetCell];
            
            if (indexPath && tweetCell.avatarImageView.image) {
                
                TweetEntity* tweet = [self tweetForIndexPath:indexPath];
                
                if (tweet.retweetedStatus) {
                    tweet = tweet.retweetedStatus;
                }
                
                savedImagesForVisibleRows[tweet.tweetId] = tweetCell.avatarImageView.image;
            }
        }
    }
    
    self.savedImagesForVisibleCells = savedImagesForVisibleRows;
}

#pragma mark -

- (void)didDeleteTweet:(TweetEntity *)tweet {
    
    @throw [NSException exceptionWithName:@"MethodMustBeOverloadedException" reason:[NSString stringWithFormat:@"%s must be overloaded", __PRETTY_FUNCTION__] userInfo:Nil];
}

@end
