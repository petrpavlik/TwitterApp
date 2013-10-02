//
//  NSTimer+Block.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/2/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(void (^)(NSTimer* timer))block userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

@end
