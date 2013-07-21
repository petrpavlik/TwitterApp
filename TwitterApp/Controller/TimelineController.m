//
//  TimelineController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TimelineController.h"

@implementation TimelineController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Timeline";
    
    
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

@end
