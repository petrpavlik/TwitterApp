//
//  LightSkin.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "LightSkin.h"
#import "UIImage+TwitterApp.h"

@implementation LightSkin

- (void)applyGlobalAppearance {
    
    UINavigationBar* navigationBar = [UINavigationBar appearance];
    
    UIColor* navigationBarColor = [UIColor colorWithRed:0.000 green:0.698 blue:0.925 alpha:1];
    
    [navigationBar setBackgroundImage:[UIImage imageWithColor:navigationBarColor] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setBackgroundImage:[UIImage imageWithColor:navigationBarColor] forBarMetrics:UIBarMetricsLandscapePhone];
    
    [navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor whiteColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica-Bold" size:18], UITextAttributeFont,
      nil]];
    
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

}

@end
