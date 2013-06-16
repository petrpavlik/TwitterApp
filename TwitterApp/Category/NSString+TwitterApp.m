//
//  NSString+TwitterApp.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NSString+TwitterApp.h"

@implementation NSString (TwitterApp)

- (NSString*)stringByStrippingHTMLTags {
    
    NSMutableString* mutableSelf = [self mutableCopy];
    
    NSRange range;
    while ((range = [mutableSelf rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        [mutableSelf deleteCharactersInRange:range];
    }
    
    NSString* outString = [mutableSelf stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    outString = [outString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&cent;" withString:@"¢"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&pound;" withString:@"£"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&yen;" withString:@"¥"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&euro;" withString:@"€"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&sect;" withString:@"§"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&copy;" withString:@"©"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&reg;" withString:@"®"];
    outString = [outString stringByReplacingOccurrencesOfString:@"&trade;" withString:@"™"];
    
    return outString;
    
}


@end
