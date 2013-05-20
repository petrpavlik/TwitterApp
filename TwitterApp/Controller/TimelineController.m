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

@interface TimelineController ()

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
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    cell.tweetTextLabel.text = tweet.text;
    cell.nameLabel.text = tweet.user.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl] placeholderImage:nil];
    
    NSArray* urls = tweet.entities[@"urls"];
    for (NSDictionary* url in urls) {
        
        NSNumber* beginningAt = url[@"indices"][0];
        NSNumber* endgingAt = url[@"indices"][1];
        NSRange range = NSMakeRange(beginningAt.integerValue, endgingAt.integerValue - beginningAt.integerValue);
        
        [cell addURL:[NSURL URLWithString:url[@"url"]] atRange:range];
    }
    
    cell.mediaImageView.hidden = YES;
    
    NSArray* media = tweet.entities[@"media"];
    for (NSDictionary* url in media) {
        
        NSNumber* beginningAt = url[@"indices"][0];
        NSNumber* endgingAt = url[@"indices"][1];
        NSRange range = NSMakeRange(beginningAt.integerValue, endgingAt.integerValue - beginningAt.integerValue);
        
        [cell addURL:[NSURL URLWithString:url[@"url"]] atRange:range];
        
        [cell.mediaImageView setImageWithURL:[NSURL URLWithString:url[@"media_url"]] placeholderImage:nil];
        cell.mediaImageView.hidden = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetEntity* tweet = self.tweets[indexPath.row];
    
    NSArray* media = tweet.entities[@"media"];
    CGFloat mediaHeight = 0;
    
    if (media.count) {
        mediaHeight = 310;
    }
    
    return [TweetCell requiredHeightForTweetText:tweet.text] + mediaHeight;
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

@end
