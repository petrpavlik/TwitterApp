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

@interface SearchController ()

@property(nonatomic, weak) NSOperation* runningSavedSearchesOperation;
@property(nonatomic, strong) NSArray* savedSearches;
@property(nonatomic, strong) id savedSearchesChangeObserver;

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
    
    if (!self.savedSearches.count) {
        [self requestData];
    }
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
        return 3;
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            // Configure the cell...
            
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
        
        SearchFieldCell* searchFieldCell = (SearchFieldCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        NSString* searchQuery = searchFieldCell.textField.text;
        
        if (!searchQuery.length) {
            return;
        }
        
        if (indexPath.row==1) { //searching tweets
            
            SearchTweetsController* searchTweetsController = [SearchTweetsController new];
            searchTweetsController.searchExpression = searchQuery;
            [self.navigationController pushViewController:searchTweetsController animated:YES];
        }
        else if (indexPath.row==2) { //searching users
            
            SearchUsersController* searchUsersController = [SearchUsersController new];
            searchUsersController.searchQuery = searchQuery;
            [self.navigationController pushViewController:searchUsersController animated:YES];
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
                
                weakSelf.savedSearches = savedSearches;
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableView endUpdates];
                
                weakSelf.navigationItem.rightBarButtonItem = weakSelf.editButtonItem;
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

@end
