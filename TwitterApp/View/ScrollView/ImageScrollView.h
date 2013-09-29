//
//  ImageScrollView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 9/7/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView

@property(nonatomic, strong) UIImage* image;
- (CGRect)frameOfZoomView;

- (void)handleDoubleTap;

@end
