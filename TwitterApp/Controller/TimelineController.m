//
//  TimelineController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TimelineController.h"
#import "TweetController.h"

@implementation TimelineController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Timeline";
    
    self.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Home"];
    self.tabBarItem.title = @"Timeline";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-Navbar-Compose"] style:UIBarButtonItemStyleBordered target:self action:@selector(composeTweet)];
    [self.navigationItem.rightBarButtonItem setImageInsets:UIEdgeInsetsMake(-1, 0, 0, -3)];
    
    self.loadNewTweetsWhenGoingForeground = YES;
    self.displayUnreadTweetIndicator = YES;
    
    /*UISearchBar* searchBar =  [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = @"Search timeline";
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.barTintColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = searchBar;*/
}

- (NSString*)tweetsPersistenceIdentifier {
    return @"timeline";
}

- (NSString*)stateRestorationIdentifier {
    return @"timeline";
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestHomeTimelineWithMaxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

#pragma mark -

- (void)composeTweet {
    
    [TweetController presentInViewController:self];
}

@end
