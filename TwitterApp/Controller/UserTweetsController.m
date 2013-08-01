//
//  UserTweetsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UserTweetsController.h"

@interface UserTweetsController ()

@end

@implementation UserTweetsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"@%@", self.screenName];
    
    self.tabBarItem.image = [UIImage imageNamed:@"Icon-TabBar-Profile"];
    self.tabBarItem.title = @"Profile";
}

- (NSString*)tweetsPersistenceIdentifier {
    
    return nil;
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestUserTimelineWithScreenName:self.screenName maxId:maxId sinceId:sinceId completionBlock:completionBlock];;
}

@end
