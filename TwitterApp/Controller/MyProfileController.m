//
//  MyProfileController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/1/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowersController.h"
#import "FollowingController.h"
#import "MyProfileController.h"
#import "ProfileCell.h"
#import "ProfilePushCell.h"
#import "UserEntity.h"
#import "TimelineController.h"
#import "UIImage+TwitterApp.h"

@interface MyProfileController ()

@property(nonatomic, strong) NSNumber* following;
@property(nonatomic, strong) UserEntity* user;

@end

@implementation MyProfileController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[ProfilePushCell class] forCellReuseIdentifier:@"ProfilePushCell"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticatedUserDidLoadNotification:) name:kAuthenticatedUserDidLoadNotification object:Nil];
    
    if ([UserEntity currentUser]) {
        self.user = [UserEntity currentUser];
    }
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
    
    if (!self.user) {
        return 0;
    }
    
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
        //cell.delegate = self;
        
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
        return 170;
    }
    else {
        return 44;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return;
    }
    
    if (indexPath.row==0) {
        
        TimelineController* timelineController = [[TimelineController alloc] initWithStyle:UITableViewStylePlain];
        timelineController.screenName = self.user.screenName;
        
        [self.navigationController pushViewController:timelineController animated:YES];
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

- (void)authenticatedUserDidLoadNotification:(NSNotification*)notification {
    
    self.user = notification.userInfo[@"user"];
    NSParameterAssert(self.user);
    
    [self.tableView reloadData];
}

@end
