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

- (NSString*)stringByRemovingEmoji {
    
    __block NSMutableString* temp = [NSMutableString string];
    
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
             
             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"XX": substring]; // U+1D000-1F77F
             
             // non surrogate
         } else {
             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"X": substring]; // U+2100-26FF
         }
     }];
    
    return temp;
}


@end
