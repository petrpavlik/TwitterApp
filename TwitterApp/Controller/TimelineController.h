//
//  TimelineController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseTweetsController.h"

@interface TimelineController : BaseTweetsController

@property(nonatomic, strong) NSString* searchQuery;
@property(nonatomic, strong) NSString* screenName;
@property(nonatomic) BOOL shouldAutoRefresh;
@property(nonatomic) BOOL shouldPersistTimeline;

@end
