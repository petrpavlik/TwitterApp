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
    
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
    cell.nameLabel.text = tweet.user.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl] placeholderImage:nil];
    
    cell.mediaImageView.hidden = YES;
    
    NSString* expandedTweet = tweet.text;
    
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
        [cell addURL:[NSURL URLWithString:url[@"expanded_url"]] atRange:[expandedTweet rangeOfString:url[@"display_url"]]];
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
        [cell addURL:[NSURL URLWithString:@""] atRange:[expandedTweet rangeOfString:hashtag]];
    }
    
    for (NSDictionary* item in mentions) {
        
        NSString* mention = [NSString stringWithFormat:@"@%@", item[@"screen_name"]];
        [cell addURL:[NSURL URLWithString:@""] atRange:[expandedTweet rangeOfString:mention]];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    if (tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
    }
    
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
        
        
        mediaHeight = [media[0][@"sizes"][@"medium"][@"h"] integerValue]/2 + 10;
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

@end
