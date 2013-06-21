//
//  NotificationView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    NotificationViewStyleInformation,
    NotificationViewStyleError
};
typedef NSUInteger NotificationViewStyle;

@interface NotificationView : UIView

+ (NotificationView*)showInView:(UIView*)view message:(NSString*)message;
+ (NotificationView*)showInView:(UIView*)view message:(NSString*)message style:(NotificationViewStyle)style;

@end
