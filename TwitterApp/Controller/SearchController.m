//
//  SearchController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SearchController.h"
#import "SearchFieldCell.h"
#import "SearchUsersController.h"
#import "SearchTweetsController.h"

@interface SearchController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[SearchFieldCell class] forCellReuseIdentifier:@"SearchFieldCell"];
    
    self.title = @"Search";
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        
        [cell resignFirstResponder];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
