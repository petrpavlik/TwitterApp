//
//  NetImageView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFImageRequestOperation.h>
#import "NetImageView.h"

static NSOperationQueue* operationQueue = nil;

@interface NetImageView ()

// queue on which to launch image request for this imge view
@property(nonatomic, weak) NSOperation* operation;

@end

@implementation NetImageView

+ (NSCache*)sharedImageCache {
    
    static NSCache *_sharedCache = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedCache = [[NSCache alloc] init];
    });
    
    return _sharedCache;
}

#pragma mark -

- (void)dealloc {
    
    [self.operation cancel];
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self setImageWithURL:url placeholderImage:placeholder imageProcessingBlock:NULL];
}

- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock {
    
    [self.operation cancel];
    
    NSURL* cachedImageUrl = url;
    
    if (self.customCacheKey) {
        cachedImageUrl = [url URLByAppendingPathExtension:self.customCacheKey];
    }
    
    if ([[NetImageView sharedImageCache] objectForKey:cachedImageUrl]) {
        
        UIImage* cachedImage = [[NetImageView sharedImageCache] objectForKey:cachedImageUrl];        
        self.image = cachedImage;

        return;
    }
    
    self.image = placeholder;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak NetImageView* weakSelf = self;
    
    AFImageRequestOperation* operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:imageProcessingBlock success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        if (image && weakSelf) {
            
            NSURL* url = request.URL;
            if (weakSelf.customCacheKey) {
                url = [url URLByAppendingPathExtension: self.customCacheKey];
            }
            
            [[NetImageView sharedImageCache] setObject:image forKey:url];
            weakSelf.image = image;
        }
        
    } failure:nil];
    
    operation.queuePriority = NSOperationQueuePriorityLow;
    
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    
    [operationQueue addOperation:operation];
    self.operation = operation;
}

- (void)setImage:(UIImage *)image {
    
    [self.operation cancel];
    [super setImage:image];
}

#pragma mark -

+ (void)setSharedOperationQueue:(NSOperationQueue *)queue {
    operationQueue = queue;
}

@end
