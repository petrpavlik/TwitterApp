//
//  ModernSkin.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/11/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreText/CoreText.h>
#import "ModernSkin.h"
#import "UIImage+TwitterApp.h"

@implementation ModernSkin

- (void)applyGlobalAppearance {
    
    //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    //AbstractSkin* skin = appDelegate.skin;
    
    UINavigationBar* navigationBar = [UINavigationBar appearance];
    UITabBar* tabBar = [UITabBar appearance];
    UIToolbar* toolBar = [UIToolbar appearance];
    
    UIColor* navigationBarColor = self.navigationBarColor;
    navigationBar.barTintColor = navigationBarColor;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    tabBar.barTintColor = [UIColor colorWithWhite:0 alpha:0.8];
    toolBar.barTintColor = self.navigationBarColor;
    
    //UIBarButtonItem* barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    //[barButtonItem setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[barButtonItem setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    //[barButtonItem setBackgroundImage:[UIImage new] forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    //[barButtonItem setBackButtonBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(20, 20)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[barButtonItem setBackButtonBackgroundImage:[UIImage new] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    //[barButtonItem setBackButtonBackgroundImage:[UIImage new] forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    /*[barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           [UIColor whiteColor], UITextAttributeTextColor,
                                           [skin fontOfSize:16], UITextAttributeFont,
                                           nil] forState:UIControlStateNormal];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           nil] forState:UIControlStateHighlighted];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           nil] forState:UIControlStateDisabled];
    
    
    [navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor], UITextAttributeTextColor,
     [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
     [skin boldFontOfSize:18], UITextAttributeFont,
     nil]];*/
     
     //[[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
     //[[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
}

- (UIFont*)fontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

- (UIFont*)boldFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

- (UIFont*)lightFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
}

- (UIColor*)linkColor {
    return [UIColor colorWithRed:0.161 green:0.502 blue:0.725 alpha:1];
}

- (UIColor*)navigationBarColor {
    return [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:0.5];
}

- (UIImage*)separatorImage {
    return [UIImage imageNamed:@"Image-Separator"];
}

@end
