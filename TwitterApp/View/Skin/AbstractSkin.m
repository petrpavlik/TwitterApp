//
//  AbstractSkin.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AbstractSkin.h"

@implementation AbstractSkin

- (UIImage*)separatorImage {
    
    @throw [NSException exceptionWithName:@"MustBeOverloadedException" reason:@"This method must be overloaded" userInfo:Nil];
}

@end
