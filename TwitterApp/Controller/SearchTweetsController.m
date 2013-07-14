//
//  SearchController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/13/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

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
}

- (NSString*)tweetsPersistenceIdentifier {
    
    return nil;
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestSearchWithQuery:self.searchExpression maxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

@end
