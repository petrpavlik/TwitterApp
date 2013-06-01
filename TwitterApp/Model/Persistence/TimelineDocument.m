//
//  TimelineDocument.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/1/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TimelineDocument.h"

@interface TimelineDocument ()

@property(nonatomic, strong) NSArray* timeline;

@end

@implementation TimelineDocument

- (id)contentsForType:(NSString*)typeName error:(NSError**)outError {
    
    NSLog(@"saving document");
    NSData* archivedTimeline = [NSKeyedArchiver archivedDataWithRootObject:self.timeline];
    return archivedTimeline;
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString*)typeName error:(NSError**)outError {
    
    NSLog(@"loading document");
    NSLog(@"%@", [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding]);
    
    if (![contents isKindOfClass:[NSData class]]) {
        
        *outError = [NSError errorWithDomain:[[self class] description] code:0 userInfo:@{NSLocalizedDescriptionKey: @"unexpected content"}];
        return NO;
    }
    
    self.timeline = [NSKeyedUnarchiver unarchiveObjectWithData:contents];
    NSLog(@"%@", self.timeline);
    
    [self.delegate timelineDocumentDidLoadPersistedTimeline:self.timeline];
    
    return YES;
}

#pragma mark -

- (void)persistTimeline:(NSArray*)tweets {
    
    self.timeline = tweets;
    [self updateChangeCount:UIDocumentChangeDone];
}

#pragma mark -

- (NSArray*)persistedTimeline {
    return _timeline;
}

@end
