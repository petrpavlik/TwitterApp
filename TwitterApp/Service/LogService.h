//
//  LogService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/25/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogService : NSObject

+ (void)instatiate;
- (void)logEvent:(NSString*)event userInfo:(NSDictionary*)userInfo;
+ (LogService*)sharedInstance;

@end
