//
//  InstapaperService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstapaperService : NSObject

+ (InstapaperService*)sharedService;

- (void)saveURL:(NSURL*)url completionHandler:(void (^)(NSURL* url, NSError* error))block;

- (void)setUsername:(NSString*)username password:(NSString*)password;
- (void)flushSavedCredentials;

@property(nonatomic, readonly) NSString* username;
@property(nonatomic, readonly) NSString* password;

@end
