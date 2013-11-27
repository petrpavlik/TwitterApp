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
#import "SwitchCell.h"
#import "SettingsService.h"
#import "ProfileController.h"

@interface SettingsController () <SwitchCellDelegate>

@end

@implementation SettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Settings";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[SwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        NSString *CellIdentifier = @"Cell";
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
    else if (indexPath.section == 1) {
        
        NSString *CellIdentifier = @"SwitchCell";
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        cell.textLabel.text = @"Tweet Marker";
        [cell.valueSwitch setOn:[SettingsService sharedService].tweetMarkerEnabled animated:NO];
        
        return cell;
    }
    else {
        
        if (indexPath.row == 0) {
            
            NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            cell.textLabel.text = @"@tweetilus";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            return cell;
        }
        else {
            
            NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

            cell.textLabel.text = @"@ptrpavlik";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    }
    
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Read Later";
    }
    else if (section == 1) {
        return @"Timeline Sync";
    }
    else {
        return @"Follow us on Twitter";
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        return @"Enable Tweet Marker to sync the reading position of your timeline betweet multiple Twitter clients.";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            
            ProfileController* profileController = [[ProfileController alloc] init];
            profileController.screenName = @"tweetilus";
            [self.navigationController pushViewController:profileController animated:YES];
        }
        else {
            
            ProfileController* profileController = [[ProfileController alloc] init];
            profileController.screenName = @"ptrpavlik";
            [self.navigationController pushViewController:profileController animated:YES];
        }
    }
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

- (void)switchCellDidToggleSwitch:(SwitchCell *)cell {
    
    [SettingsService sharedService].tweetMarkerEnabled = cell.valueSwitch.isOn;
        
}

@end
