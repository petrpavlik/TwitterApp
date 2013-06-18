//
//  BaseTweetsController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetCell.h"
#import <UIKit/UIKit.h>

@class TweetEntity;

@interface BaseTweetsController : UITableViewController <TweetCellDelegate>

- (NSString*)ageAsStringForDate:(NSDate*)date;
- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification;
- (void)applicationWillEnterForegroundNotification:(NSNotification*)notification;
- (UITableViewCell*)cellForTweet:(TweetEntity *)tweet atIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)cellForTweetDetail:(TweetEntity *)tweet atIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)heightForTweet:(TweetEntity*)tweet;
- (CGFloat)heightForTweetDetail:(TweetEntity*)tweet;
- (TweetEntity*)tweetForIndexPath:(NSIndexPath*)indexPath;

- (void)saveImagesForVisibleCells;

@end
