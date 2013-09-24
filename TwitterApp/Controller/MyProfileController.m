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
#import "SearchTweetsController.h"
#import "UserEntity.h"
#import "UIImage+TwitterApp.h"
#import "FavoritesController.h"
#import "TableViewCell.h"
#import "UserTweetsController.h"
#import "WebController.h"
#import "PhotoController.h"
#import "ImageTransition.h"
#import "NotificationView.h"
#import "PushNotificationSettingsController.h"
#import "ProfileController.h"
#import "NSString+TwitterApp.h"
#import "LoginController.h"
#import "TabBarController.h"

@interface MyProfileController () <ProfileCellDelegate>

@property(nonatomic, strong) NSNumber* following;
@property(nonatomic, strong) UserEntity* user;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, strong) UIView* headerView;
@property(nonatomic, strong) id textSizeChangedObserver;
@property(nonatomic, strong) NSMutableDictionary* cachedImagesToPersist;

@end

@implementation MyProfileController


- (NSMutableDictionary*)cachedImagesToPersist {
    
    if (!_cachedImagesToPersist) {
        _cachedImagesToPersist = [NSMutableDictionary new];
    }
    
    return _cachedImagesToPersist;
}

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Profile";
    
    [self.tableView registerClass:[ProfileCell class] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableView.tableFooterView = [UIView new];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticatedUserDidLoadNotification:) name:kAuthenticatedUserDidLoadNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:Nil];
    
    if ([UserEntity currentUser]) {
        
        self.user = [UserEntity currentUser];
        [self setupProfileBanner];
    }
    
    __weak typeof(self) weakSelf = self;
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf.tableView reloadData];
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Btn-Accounts"] style:UIBarButtonItemStyleBordered target:self action:@selector(accountsSelected)];
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
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        
        static NSString *CellIdentifier = @"ProfileCell";
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        //cell.delegate = self;
        
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
        
        [cell configureWithWebsiteAvailable:[user.entities[@"url"][@"urls"] count] locationAvailable:user.location.length];
        
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"Favorites";
            cell.detailTextLabel.text = Nil;
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        return [ProfileCell requiredHeightWithDescription:self.user.expandedUserDescription width:self.view.bounds.size.width websiteAvailable:[self.user.entities[@"url"][@"urls"] count] locationAvailable:self.user.location.length isMyProfile:YES];
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        return 20;
    }
    
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
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
    else if (indexPath.row==3) {
        
        FavoritesController* favoritesController = [[FavoritesController alloc] init];
        [self.navigationController pushViewController:favoritesController animated:YES];
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

#pragma mark -

- (void)authenticatedUserDidLoadNotification:(NSNotification*)notification {
    
    self.user = notification.userInfo[@"user"];
    NSParameterAssert(self.user);
    
    [self.tableView reloadData];
    [self setupProfileBanner];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsSelected)];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification*)notification {
    
    for (NSURL* url in [self.cachedImagesToPersist allKeys]) {
        
        UIImage* persistedImage = self.cachedImagesToPersist[url];
        [[NetImageView sharedImageCache] setObject:persistedImage forKey:url];
    }
    [self.cachedImagesToPersist removeAllObjects];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification {
    
    UserEntity* user = self.user;
    
    if (!self.user) {
        return;
    }
    
    NSURL* avatarUrl = [NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]];
    UIImage* cachedAvatarImageToPersist = [[NetImageView sharedImageCache] objectForKey:avatarUrl];
    
    if (cachedAvatarImageToPersist) {
        self.cachedImagesToPersist[avatarUrl] = cachedAvatarImageToPersist;
    }
    
    if (self.user.profileBannerUrl.length) {
        
        NSString* bannetURLString = nil;
        if ([UIScreen mainScreen].scale > 1) {
            bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile_retina"];
        }
        else {
            bannetURLString = [self.user.profileBannerUrl stringByAppendingString:@"/mobile"];
        }
        
        NSURL* bannetUrl = [NSURL URLWithString:bannetURLString];
        UIImage* cachedBannerImage = [[NetImageView sharedImageCache] objectForKey:bannetUrl];
        
        if (cachedBannerImage) {
            self.cachedImagesToPersist[bannetUrl] = cachedBannerImage;
        }
    }
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

- (void)settingsSelected {
    
    /*PushNotificationSettingsController* pushNotificationsSettingsController = [[PushNotificationSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:pushNotificationsSettingsController animated:YES];*/
    
    LoginController* loginController = [LoginController new];
    [self presentViewController:loginController animated:YES completion:NULL];
}

- (void)accountsSelected {
    
    TabBarController* tabBarController = (TabBarController*)self.tabBarController;
    [tabBarController displayListOfAccounts];
}

@end
