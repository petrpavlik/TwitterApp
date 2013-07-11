//
//  MentionsController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/1/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "MentionsController.h"

@interface MentionsController ()

@end

@implementation MentionsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Mentions";
    
    
}

- (NSString*)tweetsPersistenceIdentifier {
    
    return @"mentions";
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestMentionsTimelineWithMaxId:maxId sinceId:sinceId completionBlock:completionBlock];
}


@end
