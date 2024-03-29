//
//  TimelineDocument.h
//  TwitterApp
//
//  Created by Petr Pavlik on 6/1/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimelineDocument;

@protocol TimelineDocumentDelegate <NSObject>

- (void)timelineDocumentDidLoadPersistedTimeline:(NSArray*)tweets;

@end

@interface TimelineDocument : UIDocument

- (void)openAsync;

- (void)persistTimeline:(NSArray*)tweets;

- (NSUInteger)maxAmountOfTweetsToPersist;

@property(nonatomic, weak) id<TimelineDocumentDelegate> delegate;
//@property(nonatomic, readonly) NSArray* persistedTimeline;

@end
