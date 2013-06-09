//
//  UserListController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetEntity.h"
#import "UserCell.h"
#import "UserListController.h"

@interface UserListController ()

@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic, weak) NSOperation* runningRequestDataOperation;
@property(nonatomic, strong) NSArray* users;

@end

@implementation UserListController

- (void)dealloc {
    
    [self.runningRequestDataOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(!(self.tweetIdForRetweets.length && self.tweetIdForFavorites.length), @"cannot set both tweetIdForRetweets and tweetIdForFavorites");
    NSAssert(!(!self.tweetIdForRetweets.length && !self.tweetIdForFavorites.length), @"either tweetIdForRetweets or tweetIdForFavorites must be set");
    
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    self.tableView.rowHeight = 68;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1];
    
    if (self.tweetIdForRetweets) {
        self.title = @"Retweets";
    }
    else if (self.tweetIdForFavorites) {
        self.title = @"Favorites";
    }

    [self requestData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.users.count;
    //return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UserEntity* user = self.users[indexPath.row];
    
    cell.nameLabel.text = user.name;
    cell.usernameLabel.text = user.screenName;
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -

- (void)requestData {
    
    [self willBeginRefreshing];
    
    __weak typeof(self) weakSelf = self;
    
    self.runningRequestDataOperation = [TweetEntity requestRetweetsOfTweet:self.tweetIdForRetweets completionBlock:^(NSArray *tweets, NSError *error) {
        
        if (!tweets.count) {
            return;
        }
        
        NSMutableArray* users = [[NSMutableArray alloc] initWithCapacity:tweets.count];
        for (TweetEntity* tweet in tweets) {
            [users addObject:tweet.user];
        }
        
        weakSelf.users = users;
        [weakSelf.tableView reloadData];
        
        [weakSelf didEndRefreshing];
    }];
    
}

#pragma mark -

- (void)willBeginRefreshing {
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height, 0, 0, 0);
    self.tableView.scrollEnabled = NO;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.tableView.bounds.size.width/2, 25 - self.tableView.bounds.size.height);
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    self.activityIndicatorView = activityIndicator;
}

- (void)didEndRefreshing {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.activityIndicatorView.center = CGPointMake(self.tableView.bounds.size.width/2, 25);
        self.activityIndicatorView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.tableView.scrollEnabled = YES;
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }];
}


@end
