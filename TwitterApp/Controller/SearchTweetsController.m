//
//  SearchController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/13/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NotificationView.h"
#import "SavedSearchEntity.h"
#import "SearchTweetsController.h"

@interface SearchTweetsController ()

@end

@implementation SearchTweetsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.searchExpression.length);
    
    self.title = self.searchExpression;
    
    self.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Search"];
    self.tabBarItem.title = @"Search";
    
    if (!self.saveDisabled) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveSelected)];
    }
    
}

- (NSString*)tweetsPersistenceIdentifier {
    
    return nil;
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestSearchWithQuery:self.searchExpression maxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

#pragma mark -

- (void)saveSelected {
    
    self.navigationItem.rightBarButtonItem = nil;
    
    __weak typeof(self) weakSelf = self;
    
    [SavedSearchEntity requestSavedSearchSave:self.searchExpression completionBlock:^(SavedSearchEntity *savedSearch, NSError *error) {
       
        if (error) {
        
            [[LogService sharedInstance] logError:error];
            
            if (weakSelf) {
             
                [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not save '%@'", weakSelf.searchExpression] style:NotificationViewStyleError];
                
                weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveSelected)];;
            }
        }
        else {
            
            if (weakSelf) {
                
                [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Saved '%@'", weakSelf.searchExpression] style:NotificationViewStyleInformation];
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kSavedSearchesDidUpdateNotification object:Nil];
        }
    }];
}

@end
