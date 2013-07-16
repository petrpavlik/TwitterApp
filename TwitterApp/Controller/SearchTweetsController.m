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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveSelected)];
}

- (NSString*)tweetsPersistenceIdentifier {
    
    return nil;
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestSearchWithQuery:self.searchExpression maxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

#pragma mark -

- (void)saveSelected {
    
    __weak typeof(self) weakSelf = self;
    
    [SavedSearchEntity requestSavedSearchSave:self.searchExpression completionBlock:^(SavedSearchEntity *savedSearch, NSError *error) {
       
        if (error) {
        
            [[LogService sharedInstance] logError:error];
            
            if (weakSelf) {
                [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Could not save '%@'", weakSelf.searchExpression] style:NotificationViewStyleError];
            }
        }
        else {
            
            if (weakSelf) {
                
                [NotificationView showInView:self.notificationViewPlaceholderView message:[NSString stringWithFormat:@"Saved '%@'", weakSelf.searchExpression] style:NotificationViewStyleInformation];
                
                weakSelf.navigationItem.rightBarButtonItem = nil;
                
                //TODO: report to search controller
            }
        }
    }];
}

@end
