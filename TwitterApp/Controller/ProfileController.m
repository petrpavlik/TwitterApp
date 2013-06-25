//
//  ProfileController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ProfileController.h"
#import "ProfileCell.h"
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
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ProfileCell";
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UserEntity* user = self.user;
    
    cell.nameLabel.text = user.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    cell.descriptionLabel.text = user.userDescription;
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
        
        return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 300;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
