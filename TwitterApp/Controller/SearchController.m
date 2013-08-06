//
//  SearchController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SavedSearchEntity.h"
#import "SearchController.h"
#import "SearchFieldCell.h"
#import "SearchUsersController.h"
#import "SearchTweetsController.h"

@interface SearchController () <SearchFieldCellDelegate>

@property(nonatomic, weak) NSOperation* runningSavedSearchesOperation;
@property(nonatomic, strong) NSArray* savedSearches;
@property(nonatomic, strong) id savedSearchesChangeObserver;
@property(nonatomic, strong) NSString* searchExpression;

@end

@implementation SearchController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    [self.runningSavedSearchesOperation cancel];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.savedSearchesChangeObserver];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[SearchFieldCell class] forCellReuseIdentifier:@"SearchFieldCell"];
    
    self.title = @"Search";
    
    __weak typeof(self) weakSelf = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    self.savedSearchesChangeObserver = [center addObserverForName:kSavedSearchesDidUpdateNotification object:nil                                                      queue:Nil usingBlock:^(NSNotification *note) {
        
        [weakSelf requestData];
    }];
    
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.savedSearches.count) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        
        if (self.searchExpression.length) {
            return 3;
        }
        else {
            return 1;
        }
    }
    else {
        return self.savedSearches.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            
            static NSString *CellIdentifier = @"SearchFieldCell";
            SearchFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            // Configure the cell...
            cell.delegate = self;
            
            return cell;
        }
        else {
            
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            // Configure the cell...
            
            if (indexPath.row==1) {
                cell.textLabel.text = @"Search tweets";
            }
            else {
                cell.textLabel.text = @"Search users";
            }
            
            return cell;
        }
    }
    else {
        
        SavedSearchEntity* savedSearch = self.savedSearches[indexPath.row];
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = savedSearch.name;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        if (indexPath.row==1) { //searching tweets
            
            [self searchTweets];
        }
        else if (indexPath.row==2) { //searching users
            
            [self searchUsers];
        }
    }
    else {
        
        SavedSearchEntity* savedSearch = self.savedSearches[indexPath.row];
        
        SearchTweetsController* searchTweetsController = [SearchTweetsController new];
        searchTweetsController.searchExpression = savedSearch.query;
        [self.navigationController pushViewController:searchTweetsController animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        [cell resignFirstResponder];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section==1) {
        return @"Saved searches";
    }
    else {
        return nil;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section==1) {
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SavedSearchEntity* savedSearchToDelete = self.savedSearches[indexPath.row];
        [savedSearchToDelete requestSavedSearchDestroyWithCompletionBlock:^(NSError *error) {
           
            if (error) {
                [[LogService sharedInstance] logError:error];
            }
        }];
        
        NSMutableArray* mutableSavedSearches = [self.savedSearches mutableCopy];
        [mutableSavedSearches removeObjectAtIndex:indexPath.row];
        self.savedSearches = [mutableSavedSearches copy];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark -

- (void)requestData {
    
    if (self.runningSavedSearchesOperation) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.runningSavedSearchesOperation = [SavedSearchEntity requestSavedSearchesWithCompletionBlock:^(NSArray *savedSearches, NSError *error) {
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
        }
        else if (savedSearches.count) {
            
            if (weakSelf.savedSearches.count) {
                
                if (![weakSelf compareSavedSearches:weakSelf.savedSearches toSavedSearches:savedSearches]) {
                    
                    weakSelf.savedSearches = savedSearches;
                    
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableView endUpdates];
                    
                    weakSelf.navigationItem.rightBarButtonItem = weakSelf.editButtonItem;
                }
            }
            else {
                
                weakSelf.savedSearches = savedSearches;
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
                
                weakSelf.navigationItem.rightBarButtonItem = weakSelf.editButtonItem;
            }
        }
    }];
}

#pragma mark -

- (void)searchFieldCell:(SearchFieldCell *)cell didChangeValue:(NSString *)value {
    
    NSString* oldSearchExpression = self.searchExpression;
    self.searchExpression = value;
    
    if (!oldSearchExpression.length && self.searchExpression.length) {
        
        //show search buttons
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
    }
    else if (oldSearchExpression.length && !self.searchExpression.length) {
        
        //hide search buttons
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)searchFieldCellDidReturn:(SearchFieldCell *)cell {
    
    if (self.searchExpression.length) {
        [self searchTweets];
    }
}

#pragma mark -

- (void)searchTweets {
    
    NSParameterAssert(self.searchExpression.length);
    
    SearchTweetsController* searchTweetsController = [SearchTweetsController new];
    searchTweetsController.searchExpression = self.searchExpression;
    [self.navigationController pushViewController:searchTweetsController animated:YES];
}

- (void)searchUsers {
    
    NSParameterAssert(self.searchExpression.length);
    
    SearchUsersController* searchUsersController = [SearchUsersController new];
    searchUsersController.searchQuery = self.searchExpression;
    [self.navigationController pushViewController:searchUsersController animated:YES];
}

#pragma mark -

- (BOOL)compareSavedSearches:(NSArray*)savedSearches toSavedSearches:(NSArray*)savedSearchesToCompare {
    
    if (savedSearches.count != savedSearchesToCompare.count) {
        return NO;
    }
    
    NSInteger index = 0;
    for (SavedSearchEntity* savedSearch in savedSearches) {
        
        SavedSearchEntity* savedSearchToCompare = savedSearchesToCompare[index];
        
        if (![savedSearch.savedSearchId isEqualToString:savedSearchToCompare.savedSearchId]) {
            return NO;
        }
        
        index++;
    }
    
    return YES;
}

@end
