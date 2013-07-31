//
//  FavoritesController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FavoritesController.h"

@interface FavoritesController ()

@end

@implementation FavoritesController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Favorites";
}

- (NSOperation*)tweetDataSource:(TweetsDataSource *)dataSource requestForTweetsSinceId:(NSString*)sinceId withMaxId:(NSString*)maxId completionBlock:(void (^)(NSArray* tweets, NSError* error))completionBlock {
    
    return [TweetEntity requestFavoritesTimelineWithMaxId:maxId sinceId:sinceId completionBlock:completionBlock];
}

@end
