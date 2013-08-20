//
//  PushNotificationSettingsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 8/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "PushNotificationSettingsController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AFOAuth1Client.h"
#import "SwitchCell.h"
#import "UserEntity.h"

#define TwitterAccessToken @"TwitterAccessToken"

@interface PushNotificationSettingsController () <UIAlertViewDelegate, SwitchCellDelegate>

@property(nonatomic, strong) MSClient* msClient;
@property(nonatomic, strong) AFOAuth1Token* accessToken;

//@property(nonatomic) BOOL notificationsEnabled;

@end

@implementation PushNotificationSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[SwitchCell class] forCellReuseIdentifier:@"SwitchCell"];
    
    self.msClient = [MSClient clientWithApplicationURLString:@"https://tweetilus-pus-hmanagement.azure-mobile.net/"
                                                 applicationKey:@"JtkjmoXlKIrzOOmmbplZzUIPLRukWf73"];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSData* accessTokenData = [userDefaults objectForKey:TwitterAccessToken];
    
    
    if (!accessTokenData) {
        
        [[[UIAlertView alloc] initWithTitle:Nil message:@"Access to notifications requires separate login." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Login", nil] show];
    }
    else {
        
        self.accessToken =  [NSKeyedUnarchiver unarchiveObjectWithData:accessTokenData];
    }
    
    self.title = @"Notifications";
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.accessToken) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    else {
        
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SwitchCell";
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    if (!self.accessToken) {
        cell.valueSwitch.enabled = NO;
    }
    else {
        cell.valueSwitch.enabled = YES;
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        
        cell.textLabel.text = @"Notifications";
    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Direct Messages";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Replies";
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Mentions";
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"Favorites";
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"Retweets";
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = @"Follows";
        }
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Global settings";
    }
    else if (section == 1) {
        return @"Individual settings";
    }
    
    return nil;
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
        __weak typeof(self) weakSelf = self;
        
        AFOAuth1Client* twitterClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com/"] key:@"ip9LFL1QFBtMAeDxZhl1w" secret:@"mR06kKzyIUELyXmxBAQi5fzbcqwqPDtsqzK4vBHsE"];
        
        [twitterClient authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:[NSURL URLWithString:@"tweetilus://success"] accessTokenPath:@"oauth/access_token" accessMethod:@"POST" scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
            
            //#win
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:accessToken] forKey:TwitterAccessToken];
            [userDefaults synchronize];
            
            if (!weakSelf) {
                return;
            }
            
            weakSelf.accessToken = accessToken;
            
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
        } failure:^(NSError *error) {
            
            if (!weakSelf) {
                return;
            }
            
            [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        }];
    }
}

#pragma mark -

- (void)switchCellDidToggleSwitch:(SwitchCell *)cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (cell.valueSwitch.isOn) {
            
            NSDictionary *item = @{ @"user" : [UserEntity currentUser].screenName, @"accessToken": self.accessToken.key};
            
            MSTable *itemTable = [self.msClient tableWithName:@"PushUsers"];
            
            [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
                
                if (error) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"Request failed" message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                } else {
                    
                    [[[UIAlertView alloc] initWithTitle:@"Request succeeded" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                }
            }];
        }
        else {
            
            
        }
        
    }
}

#pragma mark -

- (void)requestData {
    
}

@end
