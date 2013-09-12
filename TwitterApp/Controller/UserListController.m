//
//  UserListController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/28/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ErrorCell.h"
#import "LoadingCell.h"
#import "NotificationView.h"
#import "ProfileController.h"
#import "TweetEntity.h"
#import "UIImage+TwitterApp.h"
#import "UserCell.h"
#import "UserListController.h"

@interface UserListController ()

@property(nonatomic, weak) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic) BOOL allUsersLoaded;
@property(nonatomic, strong) NSString* cursor;
@property(nonatomic, weak) NSOperation* runningRequestDataOperation;
@property(nonatomic, strong) id textSizeChangedObserver;

@end

@implementation UserListController

@synthesize notificationViewPlaceholderView = _notificationViewPlaceholderView;

- (void)setErrorMessage:(NSString *)errorMessage {
    
    _errorMessage = errorMessage;
    
    if ([self isViewLoaded]) {
        [self didEndRefreshing];
    }
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
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.runningRequestDataOperation cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerClass:[ErrorCell class] forCellReuseIdentifier:@"ErrorCell"];
    [self.tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    
    self.tableView.tableFooterView = [UIView new];
    //self.tableView.separatorColor = [UIColor colorWithRed:0.737 green:0.765 blue:0.784 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    [self willBeginRefreshing];
    
    [self requestData];
    
    __weak typeof(self) weakSelf = self;
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        NSIndexPath* topmostIndexPath = [weakSelf.tableView indexPathsForVisibleRows].firstObject;
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollToRowAtIndexPath:topmostIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.allUsersLoaded || self.users.count==0) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
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
            
            if (user.verified.boolValue) {
                cell.verifiedImageView.hidden = NO;
            }
            
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    self.runningRequestDataOperation = [self dataRequestOperationWithCursor:self.cursor completionBlock:^(NSArray *users, NSString *nextCursor, NSError *error) {
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            weakSelf.errorMessage = error.description;
        }
        else if (!users.count) {
            weakSelf.errorMessage = @"No users found";
        }
        else {
            
            if (nextCursor.integerValue==0) {
                weakSelf.allUsersLoaded = YES;
            }
            
            weakSelf.cursor = nextCursor;
            
            if (!weakSelf.users.count) {
                
                weakSelf.users = users;
                [weakSelf didEndRefreshing];
                
            }
            else {
                
                weakSelf.users = [weakSelf.users arrayByAddingObjectsFromArray:users];
                
                [weakSelf.tableView beginUpdates];
                
                NSMutableArray* indexPaths = [[NSMutableArray alloc] initWithCapacity:users.count];
                for (NSInteger i=0; i<users.count; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:weakSelf.users.count-users.count+i inSection:0]];
                }
                
                [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                
                if (weakSelf.allUsersLoaded) {
                    
                    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:1];
                    [weakSelf.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                    
                    if (weakSelf.tableView.contentOffset.y > 0) {
                        [NotificationView showInView:weakSelf.notificationViewPlaceholderView message:@"All users loaded"];
                    }
                }
                
                [weakSelf.tableView endUpdates];
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

#pragma mark -

- (NSOperation*)dataRequestOperationWithCursor:(NSString*)cursor completionBlock:(void (^)(NSArray *users, NSString* nextCursor, NSError *error))completionBlock {
    return nil;
}


@end
