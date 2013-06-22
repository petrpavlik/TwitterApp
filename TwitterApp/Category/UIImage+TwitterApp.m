//
//  UIImage+TwitterApp.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UIImage+TwitterApp.h"

@implementation UIImage (TwitterApp)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)imageResizedToSize:(CGSize)size {
    
    //CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, [UIScreen mainScreen].scale);
    //UIGraphicsBeginImageContext(rect.size);
    
    [self drawAtPoint:CGPointMake((size.width-self.size.width)/2, (size.height-self.size.height)/2)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static void addRoundedRectToPath(CGContextRef context,
                                 CGRect rect,
                                 float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

static void addTopRoundedRectToPath(CGContextRef context,
                                    CGRect rect,
                                    float ovalWidth,
                                    float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 0);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 0);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (UIImage *)imageWithRoundCornersWithRadius:(CGFloat)radius {
    return [self imageWithRoundCornersWithRadius:radius size:CGSizeZero];
}

- (UIImage *)imageWithRoundCornersWithRadius:(CGFloat)radius size:(CGSize)size
{
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
    if (size.width > 0) {
        w = size.width;
    }
    
    if (size.height > 0) {
        h = size.height;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextBeginPath(contextRef);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    addRoundedRectToPath(contextRef, rect, radius, radius);
    
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    [self drawInRect:CGRectMake(0, 0, w, h)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageWithRoundTopCornersWithRadius:(CGFloat)radius
{
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextBeginPath(contextRef);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    addTopRoundedRectToPath(contextRef, rect, radius, radius);
    
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    [self drawInRect:CGRectMake(0, 0, w, h)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageCroppedToRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    // or use the UIImage wherever you like
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return newImage;
}

- (UIImage *)imageScaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    CGSize size = CGSizeMake(scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [sourceImage drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageByInsertingImage:(UIImage*)overImage retina:(BOOL)retina {
    
    if (retina) {
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width*2, self.size.height*2));
        UIImage *bigSelfImage = [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:self.imageOrientation];
        [bigSelfImage drawAtPoint:CGPointMake(0, 0)];
        UIImage *bigOverImage = [UIImage imageWithCGImage:overImage.CGImage scale:1.0 orientation:overImage.imageOrientation];
        [bigOverImage drawAtPoint:CGPointMake(self.size.width - overImage.size.width, self.size.height - overImage.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    else {
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width, self.size.height));
        [self drawAtPoint:CGPointMake(0, 0)];
        [overImage drawAtPoint:CGPointMake(self.size.width/2 - overImage.size.width/2, self.size.height/2 - overImage.size.height/2)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
}

- (UIImage *)imageWithTint:(UIColor *)tintColor alpha:(CGFloat)alpha {
    
    // Begin drawing
    CGRect aRect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(aRect.size);
    //UIGraphicsBeginImageContextWithOptions(aRect.size, NO, [UIScreen mainScreen].scale);
    
    // Get the graphic context
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Converting a UIImage to a CGImage flips the image,
    // so apply a upside-down translation
    CGContextTranslateCTM(c, 0, self.size.height);
    CGContextScaleCTM(c, 1.0, -1.0);
    
    // Draw the image
    [self drawInRect:aRect];
    
    // Set the fill color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetFillColorSpace(c, colorSpace);
    
    // Set the mask to only tint non-transparent pixels
    CGContextClipToMask(c, aRect, self.CGImage);
    
    // Set the fill color
    CGContextSetFillColorWithColor(c, [tintColor colorWithAlphaComponent:alpha].CGColor);
    
    UIRectFillUsingBlendMode(aRect, kCGBlendModeColor);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Release memory
    CGColorSpaceRelease(colorSpace);
    
    return img;
}

@end
