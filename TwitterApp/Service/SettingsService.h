//
//  SettingsService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 18/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsService : NSObject

+ (SettingsService*)sharedService;

@property(nonatomic) BOOL tweetMarkerEnabled;

@end
