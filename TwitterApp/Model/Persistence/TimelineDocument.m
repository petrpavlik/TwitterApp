//
//  TimelineDocument.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/1/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TimelineDocument.h"

@interface TimelineDocument ()

@property(atomic, strong) NSArray* timeline;
@property(atomic, strong) NSData* data;

@end

@implementation TimelineDocument

- (void)openAsync {
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:self.fileURL.path]) {
        
        [self openWithCompletionHandler:^(BOOL success) {
            
            NSParameterAssert(success);
            [self.delegate timelineDocumentDidLoadPersistedTimeline:self.timeline];
        }];
        
    } else {
        
        [self saveToURL:self.fileURL forSaveOperation: UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            NSParameterAssert(success);
            [self.delegate timelineDocumentDidLoadPersistedTimeline:@[]];
        }];
    }
}

- (id)contentsForType:(NSString*)typeName error:(NSError**)outError {
    
    NSLog(@"saving document %@", [NSThread currentThread]);
    if (self.data) {
        return self.data;
    }
    else {
        return [NSData new];
    }
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
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate timelineDocumentDidLoadPersistedTimeline:self.timeline];
    });*/
    
    return YES;
}

#pragma mark -

- (void)persistTimeline:(NSArray*)tweets {
    
    NSParameterAssert([NSThread isMainThread]);
    
    if (tweets.count > self.maxAmountOfTweetsToPersist) {
        tweets = [tweets subarrayWithRange:NSMakeRange(0, self.maxAmountOfTweetsToPersist)];
    }
    else {
        tweets = [tweets copy];
    }
    
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

#pragma mark -

- (NSUInteger)maxAmountOfTweetsToPersist {
    return 500;
}

@end
