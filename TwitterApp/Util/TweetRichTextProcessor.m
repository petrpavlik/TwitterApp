//
//  TweetRichTextProcessor.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/4/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetRichTextProcessor.h"

#define kUserRegex @"((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})"
#define kHashtagRegex @"((?:^|\\s)(?:#){1}[\\w\\d]{1,140})"

@implementation TweetRichTextProcessor

+ (NSAttributedString*)processAttributedText:(NSAttributedString*)text delegate:(id <TweetRichTextProcessorDelegate>)delegate {
    
    NSMutableAttributedString* outText = [text mutableCopy];
    
    NSError *error = nil;
    
    NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:kHashtagRegex options:0 error:&error];
    for (NSTextCheckingResult *match in [hashtagRegex matchesInString:text.string options:0 range:NSMakeRange(0, text.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [outText addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
    }
    
    NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:kUserRegex options:0 error:&error];
    for (NSTextCheckingResult *match in [mentionRegex matchesInString:text.string options:0 range:NSMakeRange(0, text.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [outText addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
        
        if (delegate) {
            
            NSString* mention = [text.string substringWithRange:wordRange];
            mention = [mention stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [delegate tweetRichTextProcessorDidDetectMention:mention atRange:wordRange];
        }
    }
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    for (NSTextCheckingResult *match in [linkDetector matchesInString:text.string options:0 range:NSMakeRange(0, text.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [outText addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
    }
    
    return [outText copy];
}

@end
