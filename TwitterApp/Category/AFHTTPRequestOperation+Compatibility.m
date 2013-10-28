//
//  AFHTTPRequestOperation+Compatibility.m
//  TwitterApp
//
//  Created by Petr Pavlik on 27/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFHTTPRequestOperation+Compatibility.h"

@implementation AFHTTPRequestOperation (Compatibility)

- (void)setSuccessCallbackQueue:(dispatch_queue_t)queue {
    
    self.completionQueue = queue;
}

@end
