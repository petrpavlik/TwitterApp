//
//  SearchUsersController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ErrorCell.h"
#import "LoadingCell.h"
#import "NetImageView.h"
#import "NotificationView.h"
#import "ProfileController.h"
#import "SearchUsersController.h"
#import "UIImage+TwitterApp.h"
#import "UserCell.h"
#import "UserEntity.h"

@interface SearchUsersController ()

@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic) BOOL allUsersLoaded;
@property(nonatomic) NSInteger numPagesLoaded;
@property(nonatomic, strong) NSString* errorMessage;
@property(nonatomic, weak) NSOperation* runningRequestDataOperation;
@property(nonatomic, strong) NSArray* users;

@end

@implementation SearchUsersController

@synthesize notificationViewPlaceholderView = _notificationViewPlaceholderView;

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
    
    [self.runningRequestDataOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSParameterAssert(self.searchQuery.length);
    
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerClass:[ErrorCell class] forCellReuseIdentifier:@"ErrorCell"];
    [self.tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.automaticallyAdjustsScrollViewInsets = YES; //default YES
    
    self.title = self.searchQuery;
    
    [self willBeginRefreshing];
    
    [self requestData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.users.count || self.allUsersLoaded) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.users.count==0) {
        return 1;
    }
    
    if (section==0) {
        return self.users.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
        if (self.users.count) {
            
            static NSString *CellIdentifier = @"UserCell";
            UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            // Configure the cell...
            UserEntity* user = self.users[indexPath.row];
            
            cell.nameLabel.text = user.name;
            cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
            
            UIImage* placeholderImage = [[UIImage imageNamed:@"Img-Avatar-Placeholder"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:[user.profileImageUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]] placeholderImage:placeholderImage imageProcessingBlock:^UIImage*(UIImage* image) {
                
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
    else {
        
        [self requestData];
        
        static NSString *CellIdentifier = @"LoadingCell";
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        if (self.users.count) {
            return 68; //user cell
        }
        else {
            return self.tableView.frame.size.height; //error cell
        }
    }
    else {
        return 44; //loading cell
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.notificationViewPlaceholderView.center = CGPointMake(self.notificationViewPlaceholderView.center.x, scrollView.contentOffset.y+self.notificationViewPlaceholderView.frame.size.height/2+scrollView.contentInset.top);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    UserEntity* user = self.users[indexPath.row];
    
    ProfileController* profileController = [[ProfileController alloc] initWithStyle:UITableViewStylePlain];
    profileController.user = user;
    
    [self.navigationController pushViewController:profileController animated:YES];
}

#pragma mark -

- (void)requestData {
    
    NSLog(@"request data");
    
    if (self.runningRequestDataOperation) {
        NSLog(@"already loading data");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.runningRequestDataOperation = [UserEntity searchUsersWithQuery:self.searchQuery count:20 page:self.numPagesLoaded completionBlock:^(NSArray *users, NSError *error) {
        
        if (error) {
            
            weakSelf.errorMessage = error.description;
            [weakSelf didEndRefreshing];
        }
        else {
            
            if (!users.count || [[users.firstObject userId] isEqualToString:[weakSelf.users.lastObject userId]]) {
                
                weakSelf.allUsersLoaded = YES;
                
                if (weakSelf.numPagesLoaded==0) {
                    
                    weakSelf.errorMessage = @"No users found";
                    [weakSelf didEndRefreshing];
                }
                else {
                    
                    [weakSelf.tableView beginUpdates];
                    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:1];
                    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.tableView endUpdates];
                    
                    [NotificationView showInView:self.notificationViewPlaceholderView message:@"All users loaded"];
                }
            }
            else {
                
                weakSelf.runningRequestDataOperation = nil;
                
                if (!weakSelf.users.count) {
                    
                    weakSelf.users = users;
                    [self didEndRefreshing];
                }
                else {
                    
                    weakSelf.users = [weakSelf.users arrayByAddingObjectsFromArray:users];
                    
                    [weakSelf.tableView beginUpdates];
                    
                    NSMutableArray* indexPaths = [[NSMutableArray alloc] initWithCapacity:users.count];
                    for (NSInteger i=0; i<users.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:weakSelf.users.count-users.count+i inSection:0]];
                    }
                    
                    [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                    [weakSelf.tableView endUpdates];
                }
                
                weakSelf.numPagesLoaded++;
            }
        }
    }];
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
