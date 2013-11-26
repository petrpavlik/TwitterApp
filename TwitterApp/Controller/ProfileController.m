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
#import "AvatarTransition.h"
#import "TableViewCell.h"
#import "NSString+TwitterApp.h"
#import "UserService.h"

@interface ProfileController () <ProfileCellDelegate>

@property(nonatomic, strong) NSNumber* following;
@property(nonatomic, strong) NSNumber* followedBy;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, weak) NSOperation* runningUserOperation;
@property(nonatomic, weak) NSOperation* runningRelationshipOperation;
@property(nonatomic, weak) NSOperation* runningFollowUnfollowOperation;
@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic, strong) UIView* headerView;
@property(nonatomic, strong) id textSizeChangedObserver;

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
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.runningUserOperation cancel];
    [self.runningRelationshipOperation cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    
    self.tableView.tableFooterView = [UIView new];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.user) {
        self.title = [NSString stringWithFormat:@"@%@", self.user.screenName];
    }
    else {
        self.title = [NSString stringWithFormat:@"@%@", self.screenName];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Button-NavigationBar-Reply"] style:UIBarButtonItemStyleBordered target:self action:@selector(replySelected)];
    
    if (self.user) {
        
        [self requestDataRelationshitData];
        [self setupProfileBanner];
    }
    else {
        
        NSParameterAssert(self.screenName.length);
        [self willBeginRefreshing];
        [self requestUserData];
    }
    
    __weak typeof(self) weakSelf = self;
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.tableView indexPathForSelectedRow]) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
        
        if (self.user.protectedTweets.boolValue) {
            return 1;
        }
        else {
            return 3;
        }
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
        
        if (user.protectedTweets.boolValue) {
            NSLog(@"tweets protected");
        }
        
        cell.nameLabel.text = user.name;
        cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
        cell.descriptionLabel.text = user.expandedUserDescription;
        
        
        if (user.status) {
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.doesRelativeDateFormatting = YES;
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            
            cell.lastTweetDateLabel.text = [NSString stringWithFormat:@"Tweeted %@", [dateFormatter stringForObjectValue:user.status.createdAt]];
        }
        
        if (![[UserService sharedInstance].userId isEqualToString:self.user.userId]) {
            
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
        }
        else {
            [cell setFollowedByStatus:kFollowedByStatusUnknown];
        }
        
        if (self.runningUserOperation || self.runningRelationshipOperation || self.runningFollowUnfollowOperation) {
            
            cell.followButton.hidden = YES;
            [cell.activityIndicator startAnimating];
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
        
        NSArray* descriptionUrls = user.entities[@"description"][@"urls"];
        for (NSDictionary* urlDictionary in descriptionUrls) {
            
            NSString* expandedUrlString = urlDictionary[@"expanded_url"];
            NSString* displayUrlString = urlDictionary[@"display_url"];
            [cell addURL:[NSURL URLWithString:expandedUrlString] atRange:[user.expandedUserDescription rangeOfString:displayUrlString]];
        }
        
        NSDictionary* hashtags = user.expandedUserDescription.hashtags;
        for (NSString* hashtag in hashtags.allKeys) {
            [cell addHashtag:hashtag atRange:[hashtags[hashtag] rangeValue]];
        }
        
        NSDictionary* mentions = user.expandedUserDescription.mentions;
        for (NSString* mention in mentions.allKeys) {
            [cell addMention:mention atRange:[mentions[mention] rangeValue]];
        }
        
        UIImage* placeholderImage = [[UIImage imageNamed:@"Img-Avatar-Placeholder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:placeholderImage imageProcessingBlock:^UIImage*(UIImage* image) {
            
            return [image imageWithRoundCornersWithRadius:23.5 size:CGSizeMake(48, 48)];
        }];
        
        //[cell.avatarImageView setupImageViewer];
        
        [cell configureWithWebsiteAvailable:[user.entities[@"url"][@"urls"] count] locationAvailable:user.location.length];
        
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"TableViewCell";
        TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Tweets";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.detailTextLabel.text = [formatter stringFromNumber:self.user.statusesCount];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Followers";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.detailTextLabel.text = [formatter stringFromNumber:self.user.followersCount];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"Following";
            NSNumberFormatter* formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            cell.detailTextLabel.text = [formatter stringFromNumber:self.user.friendsCount];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        BOOL isMyProfile = NO;
        
        if (self.user && [self.user.userId isEqualToString:[UserService sharedInstance].userId]) {
            isMyProfile = YES;
        }
        
        return [ProfileCell requiredHeightWithDescription:self.user.expandedUserDescription width:self.view.bounds.size.width websiteAvailable:[self.user.entities[@"url"][@"urls"] count] locationAvailable:self.user.location.length isMyProfile:isMyProfile];
    }
    else {
        return 44;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.headerView) {
        
        if (scrollView.contentOffset.y < 0) {
            
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = 160 + (-scrollView.contentOffset.y);
            headerViewFrame.origin.y = scrollView.contentOffset.y;
            self.headerView.frame = headerViewFrame;
        }
        else {
            
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = 160;
            headerViewFrame.origin.y = 0;
            self.headerView.frame = headerViewFrame;
        }
    }
    
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
    
    if ([[UserService sharedInstance].userId isEqualToString:self.user.userId]) {
        return;
    }
    
    NSParameterAssert(self.user);
    
    __weak typeof(self)weakSelf = self;
    
    UserEntity* user = [UserEntity new];
    user.userId = [UserService sharedInstance].userId;
    
    self.runningRelationshipOperation = [user requestFriendshipStatusWithUser:self.user.userId completionBlock:^(NSNumber *following, NSNumber *followedBy, NSError *error) {
        
        weakSelf.runningRelationshipOperation = nil;
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
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
       
        weakSelf.runningUserOperation = nil;
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:@"Could not load the user" style:NotificationViewStyleError];
            return;
        }
        else {
            
            weakSelf.user = user;
            [weakSelf.tableView reloadData];
            [weakSelf requestDataRelationshitData];
            [weakSelf didEndRefreshing];
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
        
        self.runningFollowUnfollowOperation = [self.user requestUnfollowingWithCompletionBlock:^(NSError *error) {
            
            weakSelf.runningFollowUnfollowOperation = nil;
            
            if (error) {
                [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not unfollow @%@", weakSelf.user.screenName] style:NotificationViewStyleError];
            }
            else {
                weakSelf.following = [NSNumber numberWithBool:NO];
            }
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
        }];
    }
    else {
        
        self.runningFollowUnfollowOperation = [self.user requestFollowingWithCompletionBlock:^(NSError *error) {
            
            weakSelf.runningFollowUnfollowOperation = nil;
            
            if (error) {
                [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not start following @%@", weakSelf.user.screenName] style:NotificationViewStyleError];
            }
            else {
                weakSelf.following = [NSNumber numberWithBool:YES];
            }
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView endUpdates];
        }];
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)profileCell:(ProfileCell*)cell didSelectURL:(NSURL*)url {
    
    [WebController presentWithUrl:url viewController:self];
}

- (void)profileCellDidSelectAvatarImage:(ProfileCell *)cell {
    
    PhotoController* photoController = [PhotoController new];
    photoController.placeholderImage = [[UIImage imageNamed:@"Img-Avatar-Placeholder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
    photoController.fullImageURL = [NSURL URLWithString:[self.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
    
    AvatarTransition* imageTransition = [AvatarTransition new];
    
    photoController.transitioningDelegate = imageTransition;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:photoController animated:YES completion:NULL];
}

- (void)profileCellDidSelectLocation:(ProfileCell *)cell {
    
    if (self.user.location.length) {
        
        NSString* urlString = [NSString stringWithFormat:@"http://maps.apple.com?q=%@", self.user.location];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:urlString];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        else {
            
            [NotificationView showInView:self.notificationViewPlaceholderView message:@"This location cannot be openen in Maps app" style:NotificationViewStyleError];
            [[LogService sharedInstance] logError:[NSError errorWithDomain:@"Tweetilus" code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Cannot open location %@", url]}]];
        }
    }
}

- (void)profileCell:(ProfileCell *)cell didSelectHashtag:(NSString *)hashtag {
 
    SearchTweetsController* searchController = [SearchTweetsController new];
    searchController.searchExpression = hashtag;
    
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)profileCell:(ProfileCell *)cell didSelectMention:(NSString *)mention {
    
    ProfileController* profileController = [ProfileController new];
    profileController.screenName = [mention stringByReplacingOccurrencesOfString:@"@" withString:@""];
    
    [self.navigationController pushViewController:profileController animated:YES];
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
    
    NetImageView* imageView = [NetImageView new];
    imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 160);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //self.tableView.tableHeaderView = imageView;
    imageView.clipsToBounds = YES;
    
    UIView* headerPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    [headerPlaceholder addSubview:imageView];
    self.headerView = imageView;
    self.tableView.tableHeaderView = headerPlaceholder;
    
    NSString* bannetURLString = nil;
    if ([UIScreen mainScreen].scale > 1) {
        bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile_retina"];
    }
    else {
        bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile"];
    }
    
    [imageView setImageWithURL:[NSURL URLWithString:bannetURLString] placeholderImage:nil];
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
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
        
        self.activityIndicatorView.center = CGPointMake(self.tableView.bounds.size.width/2, 25);
        self.activityIndicatorView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.tableView.scrollEnabled = YES;
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }];
}

@end
