//
//  ProfileController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowersController.h"
#import "FollowingController.h"
#import "NotificationView.h"
#import "ProfileController.h"
#import "ProfileCell.h"
#import "ProfilePushCell.h"
#import "SearchTweetsController.h"
#import "UIImage+TwitterApp.h"
#import "UserEntity.h"
#import "WebController.h"

@interface ProfileController () <ProfileCellDelegate>

@property(nonatomic, strong) NSNumber* following;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;

@end

@implementation ProfileController

- (UIView*)notificationViewPlaceholderView {
    
    if (!_notificationViewPlaceholderView) {
        
        _notificationViewPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        _notificationViewPlaceholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _notificationViewPlaceholderView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_notificationViewPlaceholderView];
    }
    
    return _notificationViewPlaceholderView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.user);
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[ProfilePushCell class] forCellReuseIdentifier:@"ProfilePushCell"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
    
    [self requestData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        
        static NSString *CellIdentifier = @"ProfileCell";
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        // Configure the cell...
        UserEntity* user = self.user;
        
        cell.nameLabel.text = user.name;
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
        cell.descriptionLabel.text = user.userDescription;
        
        if (self.following) {
            
            cell.followButton.hidden = NO;
            
            if (self.following.boolValue==YES) {
                [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
                cell.followButton.selected = YES;
            }
            else {
                [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            }
        }
        
        NSArray* urls = user.entities[@"url"][@"urls"];
        if (urls.count) {
            [cell.websiteButton setTitle:user.entities[@"url"][@"urls"][0][@"expanded_url"] forState:UIControlStateNormal];
        }
        
        if (user.location) {
            [cell.locationButton setTitle:user.location forState:UIControlStateNormal];
        }
        
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
            
            return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
        }];
        
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"ProfilePushCell";
        ProfilePushCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            cell.mainLabel.text = @"Tweets";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.valueLabel.text = [formatter stringFromNumber:self.user.statusesCount];
        }
        else if (indexPath.row == 1) {
            cell.mainLabel.text = @"Followers";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.valueLabel.text = [formatter stringFromNumber:self.user.followersCount];
        }
        else if (indexPath.row == 2) {
            cell.mainLabel.text = @"Following";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.valueLabel.text = [formatter stringFromNumber:self.user.friendsCount];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        return [ProfileCell requiredHeightWithDescription:self.user.userDescription width:self.view.bounds.size.width];
    }
    else {
        return 44;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.notificationViewPlaceholderView.center = CGPointMake(self.notificationViewPlaceholderView.center.x, scrollView.contentOffset.y+self.notificationViewPlaceholderView.frame.size.height/2);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return;
    }
    
    if (indexPath.row==0) {
        
        SearchTweetsController* searchTweetsController = [SearchTweetsController new];
        searchTweetsController.searchExpression = [NSString stringWithFormat:@"from:%@", self.user.screenName];
        
        [self.navigationController pushViewController:searchTweetsController animated:YES];
    }
    else if (indexPath.row==1) {
        
        FollowersController* followersController = [[FollowersController alloc] initWithStyle:UITableViewStylePlain];
        followersController.userId = self.user.userId;
        
        [self.navigationController pushViewController:followersController animated:YES];
    }
    else if (indexPath.row==2) {
        
        FollowingController* followingController = [[FollowingController alloc] initWithStyle:UITableViewStylePlain];
        followingController.userId = self.user.userId;
        
        [self.navigationController pushViewController:followingController animated:YES];
    }
}

#pragma mark -

- (void)requestData {
    
    __weak typeof(self)weakSelf = self;
    
    [[UserEntity currentUser] requestFriendshipStatusWithUser:self.user.userId completionBlock:^(NSNumber *following, NSNumber *followedBy, NSError *error) {
        
        if (error) {
            [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:@"Could not detect following status" style:NotificationViewStyleError];
            return;
        }
        
        weakSelf.following = following;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark -

- (void)profileCellDidRequestChengeOfFriendship:(ProfileCell *)cell {
    
    if (!self.following) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    if (self.following.boolValue) {
        
        [self.user requestUnfollowingWithCompletionBlock:^(NSError *error) {
            
            if (error) {
                [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not unfollow @%@", weakSelf.user.screenName] style:NotificationViewStyleError];
                return;
            }
            
            weakSelf.following = [NSNumber numberWithBool:NO];
            [weakSelf.tableView reloadData];
        }];
    }
    else {
        
        [self.user requestFollowingWithCompletionBlock:^(NSError *error) {
            
            if (error) {
                [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not start following @%@", weakSelf.user.screenName] style:NotificationViewStyleError];
                return;
            }
            
            weakSelf.following = [NSNumber numberWithBool:YES];
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)profileCell:(ProfileCell*)cell didSelectURL:(NSURL*)url {
    
    [WebController presentWithUrl:url viewController:self];
}

@end
