//
//  NotificationView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NotificationView.h"
#import <MBProgressHUD.h>

@interface NotificationView ()

@property(nonatomic, strong) UILabel* messageLabel;

@end

@implementation NotificationView

+ (NotificationView*)showInView:(UIView*)view message:(NSString*)message {
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    [hud hide:YES afterDelay:2];
    
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)commonInit {
    
    self.backgroundColor = [UIColor greenColor];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_messageLabel];

    [_messageLabel centerInSuperview];
}

@end
