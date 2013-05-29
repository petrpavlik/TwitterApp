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
    
    UIImage* navigationBarBackground = [UIImage imageWithColor:navigationBarColor size:CGSizeMake(21, 11)];
    navigationBarBackground = [navigationBarBackground imageWithRoundTopCornersWithRadius:10];
    navigationBarBackground = [navigationBarBackground resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 0, 10)];
    
    [navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    [navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsLandscapePhone];
    
    UIBarButtonItem* barButtonItem = [UIBarButtonItem appearance];
    
    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Normal"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Highlighted"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Disabled"] forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor whiteColor], UITextAttributeTextColor,
                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                          [UIFont fontWithName:@"Helvetica-Bold" size:15], UITextAttributeFont,
                                           nil] forState:UIControlStateNormal];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor colorWithWhite:155/255.0 alpha:1], UITextAttributeTextColor,
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           [UIFont fontWithName:@"Helvetica-Bold" size:15], UITextAttributeFont,
                                           nil] forState:UIControlStateDisabled];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor colorWithWhite:212/255.0 alpha:1], UITextAttributeTextColor,
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           [UIFont fontWithName:@"Helvetica-Bold" size:15], UITextAttributeFont,
                                           nil] forState:UIControlStateHighlighted];
    
    
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
