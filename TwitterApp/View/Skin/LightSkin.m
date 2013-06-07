//
//  LightSkin.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "LightSkin.h"
#import "UIImage+TwitterApp.h"
#import <UINavigationBar+FlatUI.h>
#import <UIBarButtonItem+FlatUI.h>
#import <UIFont+FlatUI.h>

@implementation LightSkin

- (void)applyGlobalAppearance {
    
    UINavigationBar* navigationBar = [UINavigationBar appearance];
    
    UIColor* navigationBarColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    //UIColor* navigationBarColor = [UIColor colorWithRed:0.161 green:0.502 blue:0.725 alpha:1];
    [navigationBar configureFlatNavigationBarWithColor:navigationBarColor];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorWithRed:0.161 green:0.502 blue:0.725 alpha:1]
                                  highlightedColor:[UIColor colorWithRed:0.129 green:0.400 blue:0.580 alpha:1]
                                      cornerRadius:5
                                   whenContainedIn:[UINavigationBar class]];
    
    /*[barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Normal"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Highlighted"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage imageNamed:@"Button-NavigationBar-Disabled"] forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];*/
    
    UIBarButtonItem* barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           nil] forState:UIControlStateNormal];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           nil] forState:UIControlStateHighlighted];
    
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                           nil] forState:UIControlStateDisabled];
    
    
    /*[navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor whiteColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica-Bold" size:18], UITextAttributeFont,
      nil]];
    
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];*/

}

- (UIFont*)fontOfSize:(CGFloat)size {
    //return [UIFont flatFontOfSize:size];
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

- (UIFont*)boldFontOfSize:(CGFloat)size {
    //return [UIFont boldFlatFontOfSize:size];
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

//TODO: pull request to flat ui kit
- (UIFont*)lightFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    
    /*static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Lato-Light" withExtension:@"ttf"];
		CFErrorRef error;
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeNone, &error);
        error = nil;
    });
    return [UIFont fontWithName:@"Lato-Light" size:size];*/
}

- (UIColor*)linkColor {
    return [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
}

@end
