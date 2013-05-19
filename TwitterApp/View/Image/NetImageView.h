//
//  NetImageView.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetImageView : UIImageView

- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder;
+ (void)setSharedOperationQueue:(NSOperationQueue*)queue;
+ (NSCache*)sharedImageCache;

@property(nonatomic, strong) NSString* customCacheKey;

@end
