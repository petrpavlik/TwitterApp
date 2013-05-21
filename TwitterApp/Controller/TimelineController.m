//
//  TimelineController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "AFTwitterClient.h"
#import "TimelineController.h"
#import "TweetCell.h"
#import "TweetEntity.h"
#import "WebController.h"

@interface TimelineController () <TweetCellDelegate>

@property(nonatomic, strong) NSArray* tweets;

@end

@implementation TimelineController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Timeline";
    
    [self.tableView registerClass:[TweetCell class] forCellReuseIdentifier:@"TweetCell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(requestData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self requestData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    cell.tweetTextLabel.text = tweet.text;
    cell.nameLabel.text = tweet.user.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl] placeholderImage:nil];
    
    NSArray* urls = tweet.entities[@"urls"];
    for (NSDictionary* url in urls) {
        
        /*NSNumber* beginningAt = url[@"indices"][0];
        NSNumber* endgingAt = url[@"indices"][1];
        NSRange range = NSMakeRange(beginningAt.integerValue, endgingAt.integerValue - beginningAt.integerValue);
        
        [cell addURL:[NSURL URLWithString:url[@"url"]] atRange:range];*/
        
        cell.tweetTextLabel.text = [cell.tweetTextLabel.text stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
    }
    
    cell.mediaImageView.hidden = YES;
    
    NSArray* media = tweet.entities[@"media"];
    for (NSDictionary* url in media) {
        
        /*NSNumber* beginningAt = url[@"indices"][0];
        NSNumber* endgingAt = url[@"indices"][1];
        NSRange range = NSMakeRange(beginningAt.integerValue, endgingAt.integerValue - beginningAt.integerValue);
        
        [cell addURL:[NSURL URLWithString:url[@"url"]] atRange:range];*/
        
        cell.tweetTextLabel.text = [cell.tweetTextLabel.text stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
        
        [cell.mediaImageView setImageWithURL:[NSURL URLWithString:url[@"media_url"]] placeholderImage:nil];
        cell.mediaImageView.hidden = NO;
    }
    
    NSError *error = nil;
   
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:@"(\b(https?)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|])" options:0 error:&error];
    [linkRegex enumerateMatchesInString:cell.tweetTextLabel.text options:0 range:NSMakeRange(0, [cell.tweetTextLabel.text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        [cell addURL:[NSURL URLWithString:@""] atRange:result.range];
    }];
    
    NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"#([^\\s#@]*)" options:0 error:&error];
    [hashtagRegex enumerateMatchesInString:cell.tweetTextLabel.text options:0 range:NSMakeRange(0, [cell.tweetTextLabel.text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
       
        [cell addURL:[NSURL URLWithString:@""] atRange:result.range];
    }];
    
    NSRegularExpression *usernameRegex = [NSRegularExpression regularExpressionWithPattern:@"@([1-9a-zA-Z_]+)" options:0 error:&error];
    [usernameRegex enumerateMatchesInString:cell.tweetTextLabel.text options:0 range:NSMakeRange(0, [cell.tweetTextLabel.text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        [cell addURL:[NSURL URLWithString:@""] atRange:result.range];
    }];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    NSString* tweetText = tweet.text;
    
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
        mediaHeight = 310;
    }
    
    return [TweetCell requiredHeightForTweetText:tweetText] + mediaHeight;
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
                
                NSLog(@"%@", twitterAccount);
                
                [AFTwitterClient sharedClient].account = twitterAccount;
                
                [TweetEntity requestHomeTimelineWithCompletionBlock:^(NSArray *tweets, NSError *error) {
                    //NSLog(@"%@", tweets);
                    self.tweets = tweets;
                    [self.refreshControl endRefreshing];
                    [self.tableView reloadData];
                }];
                
            }
        } else {
            
            NSLog(@"No access granted %@", error);
        }
    }];
}

#pragma mark -

- (void)tweetCell:(TweetCell *)cell didSelectURL:(NSURL *)url {
    
    [WebController presentWithUrl:url viewController:self];
}

#pragma mark -

/*- (void)processTweet:(TweetEntity*)tweet {
    
    NSArray* urls = tweet.entities[@"urls"];
    NSArray* media = tweet.entities[@"media"];
    
    NSMutableArray* modifiedUrls = [urls mutableCopy];
    NSMutableArray* modifiedMedia = [media mutableCopy];
    
    for (NSDictionary* url in urls) {
        
        NSNumber* beginningAt = url[@"indices"][0];
         NSNumber* endgingAt = url[@"indices"][1];
         NSRange range = NSMakeRange(beginningAt.integerValue, endgingAt.integerValue - beginningAt.integerValue);
         
         [cell addURL:[NSURL URLWithString:url[@"url"]] atRange:range];
        
        cell.tweetTextLabel.text = [cell.tweetTextLabel.text stringByReplacingOccurrencesOfString:url[@"url"] withString:url[@"display_url"]];
    }

}*/

@end
