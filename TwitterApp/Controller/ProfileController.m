//
//  ProfileController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ProfileController.h"
#import "ProfileCell.h"
#import "ProfilePushCell.h"
#import "UIImage+TwitterApp.h"
#import "UserEntity.h"

@interface ProfileController ()

@end

@implementation ProfileController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.user);
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[ProfilePushCell class] forCellReuseIdentifier:@"ProfilePushCell"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        
        // Configure the cell...
        UserEntity* user = self.user;
        
        cell.nameLabel.text = user.name;
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
        cell.descriptionLabel.text = user.userDescription;
        
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
}


@end
