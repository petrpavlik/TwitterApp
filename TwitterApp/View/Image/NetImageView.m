//
//  NetImageView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFHTTPRequestOperation.h>
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
    [self setImageWithURL:url placeholderImage:placeholder imageProcessingBlock:imageProcessingBlock completionBlock:NULL];
}

- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock completionBlock:(void (^)(NetImageView *imageView, NSError* error))completionBlock {
    
    [self.operation cancel];
    
    NSURL* cachedImageUrl = url;
    
    if (self.customCacheKey) {
        cachedImageUrl = [url URLByAppendingPathExtension:self.customCacheKey];
    }
    
    if ([[NetImageView sharedImageCache] objectForKey:cachedImageUrl]) {
        
        UIImage* cachedImage = [[NetImageView sharedImageCache] objectForKey:cachedImageUrl];        
        self.image = cachedImage;

        if (completionBlock) {
            completionBlock(self, Nil);
        }
        
        return;
    }
    
    self.image = placeholder;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak NetImageView* weakSelf = self;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFImageResponseSerializer* responseSerializer = [AFImageResponseSerializer serializer];
    operation.responseSerializer = responseSerializer;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        UIImage* image = responseObject;
        
        if (image && weakSelf) {
            
            if (imageProcessingBlock) {
                image = imageProcessingBlock(image);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSURL* url = operation.request.URL;
                if (weakSelf.customCacheKey) {
                    url = [url URLByAppendingPathExtension: self.customCacheKey];
                }
                
                [[NetImageView sharedImageCache] setObject:image forKey:url];
                weakSelf.image = image;
                
                if (completionBlock) {
                    completionBlock(weakSelf, Nil);
                }
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionBlock) {
            completionBlock(Nil, error);
        }
    }];
    
    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    operation.queuePriority = NSOperationQueuePriorityLow;
    
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        
        if (cachedResponse) {
            
            NSCachedURLResponse* newCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:cachedResponse.userInfo storagePolicy:NSURLCacheStorageAllowed];
            
            return newCachedResponse;
        }
        else {
            return nil;
        }
    }];
    
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
