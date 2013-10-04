//
//  TweetRichTextProcessor.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/4/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TweetRichTextProcessor;

@protocol TweetRichTextProcessorDelegate <NSObject>

- (void)tweetRichTextProcessorDidDetectMention:(NSString*)mention atRange:(NSRange)range;

@end

@interface TweetRichTextProcessor : NSObject

+ (NSAttributedString*)processAttributedText:(NSAttributedString*)text delegate:(id <TweetRichTextProcessorDelegate>)delegate;

@end
