//
//  AFHTTPRequestOperation+Compatibility.h
//  TwitterApp
//
//  Created by Petr Pavlik on 27/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (Compatibility)

- (void)setSuccessCallbackQueue:(dispatch_queue_t)queue __deprecated;

@end
