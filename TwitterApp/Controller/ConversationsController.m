//
//  ConversationsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ConversationsController.h"

@interface ConversationsController ()

@property(nonatomic, strong) NSArray* conversations;

@end

@implementation ConversationsController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
