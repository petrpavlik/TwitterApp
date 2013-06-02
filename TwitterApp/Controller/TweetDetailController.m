//
//  TweetDetailController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NSString+TwitterApp.h"
#import "TweetCell.h"
#import "TweetDetailController.h"
#import "TweetEntity.h"

@interface TweetDetailController ()

@property(nonatomic, strong) NSArray* olderRelatedTweets;
@property(nonatomic, strong) NSArray* replies;

@end

@implementation TweetDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert(self.tweet);
    
    self.title = @"Tweet Detail";
    
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:@"TweetCell"];
    
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
    
    TweetEntity* tweet = nil;
    
    if (indexPath.section == 0) {
        tweet = self.replies[indexPath.row];
    }
    else if (indexPath.section == 1) {
        tweet = self.tweet;
    }
    else if (indexPath.section == 2) {
        tweet = self.olderRelatedTweets[indexPath.row];
    }
    else {
        NSAssert(NO, @"unknown section index");
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = nil;
    
    if (indexPath.section == 0) {
        tweet = self.replies[indexPath.row];
    }
    else if (indexPath.section == 1) {
        tweet = self.tweet;
    }
    else if (indexPath.section == 2) {
        tweet = self.olderRelatedTweets[indexPath.row];
    }
    else {
        NSAssert(NO, @"unknown section index");
    }
    
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
    
    [TweetEntity requestSearchRepliesWithTweetId:self.tweet.tweetId screenName:self.tweet.user.screenName completionBlock:^(NSArray *tweets, NSError *error) {
        
        self.replies = tweets;
        [self.tableView reloadData];
    }];
}

- (void)requestOlderRelatedTweetToTweetId:(NSString*)tweetId {
    
    NSParameterAssert(tweetId);
    
    [TweetEntity requestTweetWithId:tweetId completionBlock:^(TweetEntity *tweet, NSError *error) {
       
        if (tweet) {
            
            if (!self.olderRelatedTweets) {
                self.olderRelatedTweets = @[tweet];
            }
            else {
                self.olderRelatedTweets = [self.olderRelatedTweets arrayByAddingObject:tweet];
            }
            
            [self.tableView reloadData];
            
            if (tweet.inReplyToStatusId) {
                [self requestOlderRelatedTweetToTweetId:tweetId];
            }
        }
    }];
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

@end
