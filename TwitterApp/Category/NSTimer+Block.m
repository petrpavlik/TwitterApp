//
//  NSTimer+Block.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NSTimer+Block.h"

typedef void (^TimerBlock) (NSTimer* timer);

@interface TimerTarger : NSObject

- (void)timerFired:(NSTimer*)timer;

@property(nonatomic, copy) TimerBlock block;

@end

@implementation TimerTarger

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"timer deallocated");
#endif
}

- (void)timerFired:(NSTimer*)timer {
    
    //NSLog(@"timer fired");
    self.block(timer);
}

@end

@implementation NSTimer (Block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(NSTimer* timer))block userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    
    TimerTarger* timerTarget = [TimerTarger new];
    timerTarget.block = block;
    
    return [NSTimer scheduledTimerWithTimeInterval:ti target:timerTarget selector:@selector(timerFired:) userInfo:userInfo repeats:yesOrNo];
}

@end
