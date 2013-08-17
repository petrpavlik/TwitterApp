//
//  TwitterAppWindow.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/29/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TwitterAppWindow.h"

@interface TwitterAppWindow ()

@property(nonatomic, strong) UILabel* notificaitonLabel;

@end

@implementation TwitterAppWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.layer.cornerRadius = 10;
        //self.clipsToBounds = YES;
        [self commonSetup];
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

- (void)commonSetup {
    
    /*_notificaitonLabel = [UILabel new];
    _notificaitonLabel.textAlignment = NSTextAlignmentCenter;
    _notificaitonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    _notificaitonLabel.textColor = [UIColor whiteColor];
    _notificaitonLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 20);
    _notificaitonLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _notificaitonLabel.text = @"1:35 PM";
    [self addSubview:_notificaitonLabel];*/
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    [self bringSubviewToFront:self.notificaitonLabel];
}

- (void)presentStatusBarNotificationWithText:(NSString*)text {
    
}

@end
