//
//  UIImage+TwitterApp.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TwitterApp)

- (UIImage *)imageWithRoundCornersWithRadius:(CGFloat)radius size:(CGSize)size;
- (UIImage *)imageWithRoundCornersWithRadius:(CGFloat)radius;
- (UIImage *)imageWithRoundTopCornersWithRadius:(CGFloat)radius;
- (UIImage *)imageCroppedToRect:(CGRect)rect;
- (UIImage *)imageScaledToSize:(CGSize)newSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByInsertingImage:(UIImage*)overImage retina:(BOOL)retina;

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;

@end
