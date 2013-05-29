//
//  TwitterAppWindow.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/29/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TwitterAppWindow.h"

@implementation TwitterAppWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
