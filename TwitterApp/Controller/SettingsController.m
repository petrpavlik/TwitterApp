//
//  SettingsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 26/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SettingsController.h"
#import <PocketAPI.h>
#import "InstapaperService.h"
#import "AppDelegate.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Settings";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = [appDelegate skin];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"Pocket";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton* accessoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        if ([PocketAPI sharedAPI].isLoggedIn) {
            
            accessoryButton.tintColor = [UIColor redColor];
            [accessoryButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        }
        else {
            
            accessoryButton.tintColor = skin.linkColor;
            [accessoryButton setTitle:@"Sign In" forState:UIControlStateNormal];
        }
        
        accessoryButton.frame = CGRectMake(0, 0, accessoryButton.intrinsicContentSize.width, 44);
        [accessoryButton addTarget:self action:@selector(pocketSelected) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accessoryButton;
    }
    else {
        
        cell.textLabel.text = @"Instapaper";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton* accessoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        if ([InstapaperService sharedService].isLoggedIn) {
            
            accessoryButton.tintColor = [UIColor redColor];
            [accessoryButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        }
        else {
            
            accessoryButton.tintColor = skin.linkColor;
            [accessoryButton setTitle:@"Sign In" forState:UIControlStateNormal];
        }
        
        accessoryButton.frame = CGRectMake(0, 0, accessoryButton.intrinsicContentSize.width, 44);
        [accessoryButton addTarget:self action:@selector(instapaperSelected) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accessoryButton;
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Read Later";
}

#pragma mark -

- (void)pocketSelected {
    
    if ([PocketAPI sharedAPI].isLoggedIn) {
        
        [[PocketAPI sharedAPI] logout];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else {
        
        __weak typeof(self) weakSelf = self;
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error) {
            
            if (error) {
                
                [[[UIAlertView alloc] initWithTitle:@"Pocket Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{ //isLoggedIn set set after this block is finished, so I call dispatch_async

                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableView endUpdates];
                });
            }
        }];
    }
}

- (void)instapaperSelected {
    
    if ([InstapaperService sharedService].isLoggedIn) {
        
        [[InstapaperService sharedService] flushSavedCredentials];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else {
        
        __weak typeof(self) weakSelf = self;
        [[InstapaperService sharedService] loginWithCompletionHandler:^(NSError *error) {
           
            if (!error) {
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableView endUpdates];
            }
        }];
    }
}

@end
