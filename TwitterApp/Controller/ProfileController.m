//
//  ProfileController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowersController.h"
#import "FollowingController.h"
#import "MHFacebookImageViewer.h"
#import "NotificationView.h"
#import "ProfileController.h"
#import "ProfileCell.h"
#import "ProfilePushCell.h"
#import "SearchTweetsController.h"
#import "TweetController.h"
#import "UIImage+TwitterApp.h"
#import "UserEntity.h"
#import "WebController.h"
#import "UserTweetsController.h"
#import "PhotoController.h"
#import "ImageTransition.h"

@interface ProfileController () <ProfileCellDelegate>

@property(nonatomic, strong) NSNumber* following;
@property(nonatomic, strong) NSNumber* followedBy;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, weak) NSOperation* runningUserOperation;
@property(nonatomic, weak) NSOperation* runningRelationshipOperation;

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

- (void)dealloc {
    
    [self.runningUserOperation cancel];
    [self.runningRelationshipOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[ProfilePushCell class] forCellReuseIdentifier:@"ProfilePushCell"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.user) {
        self.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
    }
    else {
        self.title = [NSString stringWithFormat:@"@%@", self.screenName];
    }
    
    UIButton* spamOrReportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    spamOrReportButton.frame = CGRectMake(0, 0, 0, 70);
    [spamOrReportButton setTitle:@"Block or Report" forState:UIControlStateNormal];
    spamOrReportButton.tintColor = [UIColor colorWithRed:0.827 green:0.361 blue:0.310 alpha:1];
    [spamOrReportButton addTarget:self action:@selector(spamOrReportSelected) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = spamOrReportButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Button-NavigationBar-Reply"] style:UIBarButtonItemStyleBordered target:self action:@selector(replySelected)];
    
    if (self.user) {
        
        [self requestDataRelationshitData];
        [self setupProfileBanner];
    }
    else {
        
        NSParameterAssert(self.screenName.length);
        [self requestUserData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.user) {
        return 2;
    }
    else {
        return 0;
    }
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
        cell.descriptionLabel.text = user.expandedUserDescription;
        
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
        
        if (self.followedBy) {
            
            if (self.followedBy.boolValue) {
                [cell setFollowedByStatus:kFollowedByStatusYes];
            }
            else {
                [cell setFollowedByStatus:kFollowedByStatusNo];
            }
        }
        else {
            [cell setFollowedByStatus:kFollowedByStatusUnknown];
        }
        
        NSArray* urls = user.entities[@"url"][@"urls"];
        if (urls.count) {
            [cell.websiteButton setTitle:user.entities[@"url"][@"urls"][0][@"expanded_url"] forState:UIControlStateNormal];
            cell.websiteButton.hidden = NO;
        }
        else {
            cell.websiteButton.hidden = YES;
        }
        
        if (user.location.length) {
            [cell.locationButton setTitle:user.location forState:UIControlStateNormal];
            cell.locationButton.hidden = NO;
        }
        else {
            cell.locationButton.hidden = YES;
        }
        
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:nil imageProcessingBlock:^UIImage*(UIImage* image) {
            
            return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
        }];
        
        //[cell.avatarImageView setupImageViewer];
        
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
        return [ProfileCell requiredHeightWithDescription:self.user.expandedUserDescription width:self.view.bounds.size.width];
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
        
        UserTweetsController* userTweetsController = [UserTweetsController new];
        userTweetsController.screenName = self.user.screenName;
        
        [self.navigationController pushViewController:userTweetsController animated:YES];
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

- (void)requestDataRelationshitData {
    
    NSParameterAssert(self.user);
    
    __weak typeof(self)weakSelf = self;
    
    self.runningRelationshipOperation = [[UserEntity currentUser] requestFriendshipStatusWithUser:self.user.userId completionBlock:^(NSNumber *following, NSNumber *followedBy, NSError *error) {
        
        if (error) {
            [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:@"Could not detect following status" style:NotificationViewStyleError];
            return;
        }
        
        weakSelf.following = following;
        weakSelf.followedBy = followedBy;
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestUserData {
    
    NSParameterAssert(self.screenName.length);
    
    __weak typeof(self) weakSelf = self;
    
    self.runningUserOperation = [UserEntity requestUserWithScreenName:self.screenName completionBlock:^(UserEntity *user, NSError *error) {
       
        if (error) {
            
            
        }
        else {
            
            weakSelf.user = user;
            [weakSelf.tableView reloadData];
            [weakSelf requestDataRelationshitData];
            [weakSelf setupProfileBanner];
        }
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

- (void)profileCellDidSelectAvatarImage:(ProfileCell *)cell {
    
    PhotoController* photoController = [PhotoController new];
    photoController.placeholderImage = [[UIImage imageNamed:@"Img-Avatar-Placeholder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
    photoController.fullImageURL = [NSURL URLWithString:[self.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
    
    ImageTransition* imageTransition = [ImageTransition new];
    
    photoController.transitioningDelegate = imageTransition;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:photoController animated:YES completion:NULL];
}

#pragma mark -

- (void)replySelected {
    
    [TweetController presentInViewController:self prefilledText:[NSString stringWithFormat:@"@%@ ", self.user.screenName]];
}

#pragma mark - profile banner

- (void)setupProfileBanner {
    
    NSParameterAssert(self.user);
    
    if (!self.user.profileBannerUrl.length) {
        return; //no background image set up
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(-150, 0, 0, 0);
    
    NetImageView* imageView = [NetImageView new];
    imageView.frame = CGRectMake(0, 0, 0, 160);
    self.tableView.tableHeaderView = imageView;
    
    NSString* bannetURLString = nil;
    if ([UIScreen mainScreen].scale > 1) {
        bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile_retina"];
    }
    else {
        bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile"];
    }
    
    [imageView setImageWithURL:[NSURL URLWithString:bannetURLString] placeholderImage:nil];
}

- (void)spamOrReportSelected {
    
    
}

@end
