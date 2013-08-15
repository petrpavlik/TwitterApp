//
//  ComposeTweetTextStorage.m
//  TwitterApp
//
//  Created by Petr Pavlik on 8/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ComposeTweetTextStorage.h"

#define kUserRegex @"((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})"
#define kHashtagRegex @"((?:^|\\s)(?:#){1}[\\w\\d]{1,140})"

@interface ComposeTweetTextStorage ()

@property(nonatomic, strong) NSMutableAttributedString* backingStore;
@property(nonatomic) BOOL dynamicTextNeedsUpdate;

@end

@implementation ComposeTweetTextStorage

/* Note for subclassing NSTextStorage: NSTextStorage is a semi-abstract subclass of NSMutableAttributedString. It implements change management (beginEditing/endEditing), verification of attributes, delegate handling, and layout management notification. The one aspect it does not implement is the actual attributed string storage --- this is left up to the subclassers, which need to override the two NSMutableAttributedString primitives in addition to two NSAttributedString primitives:
 
 - (NSString *)string;
 - (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range;
 
 - (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
 - (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;
 
 These primitives should perform the change then call edited:range:changeInLength: to get everything else to happen.
 */

- (NSMutableAttributedString*)backingStore {
    
    if (!_backingStore) {
        _backingStore = [NSMutableAttributedString new];
    }
    
    return _backingStore;
}

- (NSString *)string
{
    return [self.backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [self.backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [self.backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange
{
    [self removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.backingStore.string.length)];
    
    //NSRange extendedRange = NSUnionRange(changedRange, [[self.backingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    //extendedRange = NSUnionRange(changedRange, [[self.backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    
    NSRange spaceBeforeRange = [self.backingStore.string rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, changedRange.location)];
    NSRange spaceAfterRange = [self.backingStore.string rangeOfString:@" " options:0 range:NSMakeRange(changedRange.location, self.backingStore.string.length-changedRange.location)];
    
    NSRange extendedRange = NSMakeRange(0, self.backingStore.string.length);

    if (spaceBeforeRange.location != NSNotFound) {
        extendedRange.location = spaceBeforeRange.location;
        extendedRange.length -= extendedRange.location;
    }
    
    if (spaceAfterRange.location != NSNotFound) {
        extendedRange.length = spaceAfterRange.location - extendedRange.location;
    }
    
    //[self applyTokenAttributesToRange:extendedRange];
    //[self addAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } range:extendedRange];
    
    NSError *error = nil;
    
    NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:kHashtagRegex options:0 error:&error];
    for (NSTextCheckingResult *match in [hashtagRegex matchesInString:self.backingStore.string options:0 range:NSMakeRange(0, self.backingStore.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [self addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
    }
    
    NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:kUserRegex options:0 error:&error];
    for (NSTextCheckingResult *match in [mentionRegex matchesInString:self.backingStore.string options:0 range:NSMakeRange(0, self.backingStore.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [self addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
    }
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    for (NSTextCheckingResult *match in [linkDetector matchesInString:self.backingStore.string options:0 range:NSMakeRange(0, self.backingStore.string.length)]) {
        
        NSRange wordRange = [match rangeAtIndex:0];
        [self addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1]} range:wordRange];
    }
}

-(void)processEditing
{
    if(_dynamicTextNeedsUpdate)
    {
        _dynamicTextNeedsUpdate = NO;
        [self performReplacementsForCharacterChangeInRange:[self editedRange]];
    }
    [super processEditing];
}

/*- (void)applyTokenAttributesToRange:(NSRange)searchRange
{
    NSDictionary *defaultAttributes = [self.tokens objectForKey:TKDDefaultTokenName];
    
    [[self.backingStore string] enumerateSubstringsInRange:searchRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSDictionary *attributesForToken = [self.tokens objectForKey:substring];
        if(!attributesForToken)
            attributesForToken = defaultAttributes;
        
        if(attributesForToken)
            [self addAttributes:attributesForToken range:substringRange];
    }];
}*/

@end
