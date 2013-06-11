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
@property(nonatomic, strong) NSData* data;

@end

@implementation TimelineDocument

- (id)contentsForType:(NSString*)typeName error:(NSError**)outError {
    
    NSLog(@"saving document %@", [NSThread currentThread]);
    return self.data;
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString*)typeName error:(NSError**)outError {
    
    NSLog(@"loading document %@", [NSThread currentThread]);
    //NSLog(@"%@", [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding]);
    
    if (![contents isKindOfClass:[NSData class]]) {
        
        *outError = [NSError errorWithDomain:[[self class] description] code:0 userInfo:@{NSLocalizedDescriptionKey: @"unexpected content"}];
        return NO;
    }
    
    self.data = contents;
    self.timeline = [NSKeyedUnarchiver unarchiveObjectWithData:contents];
    //NSLog(@"%@", self.timeline);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate timelineDocumentDidLoadPersistedTimeline:self.timeline];
    });
    
    return YES;
}

#pragma mark -

- (void)persistTimeline:(NSArray*)tweets {
    
    NSParameterAssert([NSThread isMainThread]);
    
    tweets = [tweets copy];
    self.timeline = tweets;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSData* archivedTimeline = [NSKeyedArchiver archivedDataWithRootObject:tweets];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.data = archivedTimeline;
            [self updateChangeCount:UIDocumentChangeDone];
        });
    });
}

#pragma mark -

- (NSArray*)persistedTimeline {
    
    NSParameterAssert([NSThread isMainThread]);
    
    return _timeline;
}

@end
