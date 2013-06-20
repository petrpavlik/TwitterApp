//
//  NotificationView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NotificationView.h"
#import <MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface NotificationView ()

@property(nonatomic, strong) UILabel* messageLabel;

@end

@implementation NotificationView

+ (NotificationView*)showInView:(UIView*)view message:(NSString*)message {
    
    CGFloat width = 260;
    CGFloat leftMargin = (view.bounds.size.width-width)/2;
    
    NotificationView* notificationView = [[NotificationView alloc] initWithFrame:CGRectMake(leftMargin, 10, width, 44)];
    notificationView.messageLabel.text = message;
    notificationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:notificationView];
    
    notificationView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        notificationView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:3 options:0 animations:^{
            
            notificationView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [notificationView removeFromSuperview];
        }];
    }];
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    AbstractSkin* skin = [(AppDelegate*)[UIApplication sharedApplication].delegate skin];
    
    self.backgroundColor = skin.navigationBarColor;
    self.layer.cornerRadius = 22;
    self.clipsToBounds = YES;
    
    self.layer.shouldRasterize = YES;
    // Not setting rasterizationScale, will cause blurry images on retina displays:
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = [skin boldFontOfSize:16];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _messageLabel.backgroundColor = self.backgroundColor;
    
    [self addSubview:_messageLabel];

    [_messageLabel centerInSuperview];
}

@end
