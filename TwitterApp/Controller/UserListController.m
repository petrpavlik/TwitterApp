//
//  UserListController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ErrorCell.h"
#import "ProfileController.h"
#import "TweetEntity.h"
#import "UIImage+TwitterApp.h"
#import "UserCell.h"
#import "UserListController.h"

@interface UserListController ()

@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic, weak) NSOperation* runningRequestDataOperation;

@end

@implementation UserListController

- (void)setUsers:(NSArray *)users {
    
    _users = users;
    
    if ([self isViewLoaded]) {
        [self didEndRefreshing];
    }
}

- (void)setErrorMessage:(NSString *)errorMessage {
    
    _errorMessage = errorMessage;
    
    if ([self isViewLoaded]) {
        [self didEndRefreshing];
    }
}

- (void)dealloc {
    
    [self.runningRequestDataOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerClass:[ErrorCell class] forCellReuseIdentifier:@"ErrorCell"];
    //self.tableView.rowHeight = 68;
    self.tableView.tableFooterView = [UIView new];
    //self.tableView.separatorColor = [UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self willBeginRefreshing];
    self.runningRequestDataOperation = [self dataRequestOperation];
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
    return MAX(self.users.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.users.count) {
        
        static NSString *CellIdentifier = @"UserCell";
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        UserEntity* user = self.users[indexPath.row];
        
        cell.nameLabel.text = user.name;
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
            
            return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
        }];
        
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"ErrorCell";
        ErrorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        cell.errorLabel.text = self.errorMessage;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.users.count) {
        return 68;
    }
    else {
        return self.tableView.frame.size.height; //error cell
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserEntity* user = self.users[indexPath.row];
    
    ProfileController* profileController = [[ProfileController alloc] initWithStyle:UITableViewStylePlain];
    profileController.user = user;
    
    [self.navigationController pushViewController:profileController animated:YES];
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
    
    if (self.tableView.contentInset.top == 0) {
        return;
    }
    
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

#pragma mark -

- (NSOperation*)dataRequestOperation {
    return nil;
}


@end
