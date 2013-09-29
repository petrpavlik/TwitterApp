//
//  ImageTransition.m
//  TwitterApp
//
//  Created by Petr Pavlik on 8/3/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ImageTransition.h"

@interface ImageTransition ()

@property(nonatomic) BOOL isDismissing;
@property(nonatomic) CGRect finalFrameWhenDismissing;

@end

@implementation ImageTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [fromVC view];
    UIView *toView = [toVC view];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    
    if (self.isDismissing) {
        
        UIGraphicsBeginImageContextWithOptions(toView.bounds.size, YES, [UIScreen mainScreen].scale);
        [toView drawViewHierarchyInRect:toView.bounds afterScreenUpdates:YES];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView* toViewBackground = [[UIImageView alloc] initWithImage:snapshot];
        [inView addSubview:toViewBackground];
    }
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:inView.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    if (!self.isDismissing) {
        backgroundView.alpha = 0;
    }
    [inView addSubview:backgroundView];
    
    CGRect initialImageRect = self.initialImageRect;
    
    if (!self.isDismissing) {
        
        if (self.image.size.width < initialImageRect.size.width) {
            
            initialImageRect.origin.x += (initialImageRect.size.width - self.image.size.width)/2;
            initialImageRect.size.width = self.image.size.width;
        }
        
        self.finalFrameWhenDismissing = initialImageRect;
    }
    
    CGFloat finalRectHeight = self.image.size.height * (inView.bounds.size.width / self.image.size.width);
    CGRect finalImageRect = CGRectMake(0, (inView.bounds.size.height-finalRectHeight)/2, inView.bounds.size.width, finalRectHeight);
    
    if (self.isDismissing) {
        finalImageRect = self.finalFrameWhenDismissing;
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:initialImageRect];
    imageView.image = self.image;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [inView addSubview:imageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (!self.isDismissing) {
            backgroundView.alpha = 1;
        }
        else {
            backgroundView.alpha = 0;
        }
        imageView.frame = finalImageRect;
     
    } completion:^(BOOL finished) {
        
        [backgroundView removeFromSuperview];
        [imageView removeFromSuperview];
        
         if ([transitionContext transitionWasCancelled]) {
             [transitionContext completeTransition:NO];
         }
         else {
             [inView addSubview:toView];
             [fromView removeFromSuperview];
             [transitionContext completeTransition:YES];
         }
        
        if (self.isDismissing && self.controllerDismissedBlock) {
            self.controllerDismissedBlock();
        }
        
        self.isDismissing = YES;
     }];
}

#pragma mark - Transitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


@end
