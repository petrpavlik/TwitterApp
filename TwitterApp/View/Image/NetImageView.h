//
//  NetImageView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetImageView : UIImageView
//(UIImage *(^)(UIImage *))imageProcessingBlock
- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder;
- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock;
- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock completionBlock:(void (^)(NetImageView *imageView, NSError* error))completionBlock;
+ (void)setSharedOperationQueue:(NSOperationQueue*)queue;
+ (NSCache*)sharedImageCache;

@property(nonatomic, strong) NSString* customCacheKey;

@end
