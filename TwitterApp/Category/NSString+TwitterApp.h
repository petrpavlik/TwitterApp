//
//  NSString+TwitterApp.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TwitterApp)

- (NSString*)stringByStrippingHTMLTags;
- (NSString*)stringByRemovingEmoji;

- (NSDictionary*)hashtags;
- (NSDictionary*)mentions;

@end
