//
//  SettingsService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 18/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SettingsService.h"

@implementation SettingsService

+ (SettingsService*)sharedService {
    
    static SettingsService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SettingsService alloc] init];
    });
    
    return _sharedClient;
}

- (void)setTweetMarkerEnabled:(BOOL)tweetMarkerEnabled {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:tweetMarkerEnabled forKey:kUserDefaultsKeyTweetMarkerEnabled];
    [userDefaults synchronize];
}

- (BOOL)tweetMarkerEnabled {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kUserDefaultsKeyTweetMarkerEnabled];
}

@end
