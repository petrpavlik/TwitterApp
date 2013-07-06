//
//  BasementController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BasementController.h"
#import <ECSlidingViewController.h>

@interface BasementController ()

@property(nonatomic, strong) NSArray* menuItems;

@end

@implementation BasementController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.view.backgroundColor = [UIColor blackColor];
    
    [self.slidingViewController setAnchorRightRevealAmount:120.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    tableHeaderView.backgroundColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    self.tableView.tableHeaderView = tableHeaderView;
    
    self.menuItems = @[@"Timeline", @"Search"];
    
    /*CGFloat longestMenuItemTextLength = [self.menuItems[0] sizewithfo;
    for (NSString* menuItemText in self.menuItems) {
        if
    }*/
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
    
    if (indexPath.row==0) {
        cell.textLabel.text = @"Timeline";
    }
    else if (indexPath.row==1) {
        cell.textLabel.text = @"Search";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
