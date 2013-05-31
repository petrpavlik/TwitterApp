//
//  NotificationView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationView : UIView

+ (NotificationView*)showInView:(UIView*)view message:(NSString*)message;

@end
