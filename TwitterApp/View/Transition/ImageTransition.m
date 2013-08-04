//
//  ImageTransition.m
//  TwitterApp
//
//  Created by Petr Pavlik on 8/3/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ImageTransition.h"

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
    
    // Take a snapshot of the new view being presented
    /*UIGraphicsBeginImageContextWithOptions(toView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [toView.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();*/
    
    UIGraphicsBeginImageContextWithOptions(toView.bounds.size, YES, [UIScreen mainScreen].scale);
    [toView drawViewHierarchyInRect:toView.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    // Add the snapshot view and animate its appearance
    UIImageView *intermediateView = [[UIImageView alloc] initWithImage:snapshot];
    [inView addSubview:intermediateView];
    inView.alpha = 0;
    inView.layer.shouldRasterize = YES;
    inView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    //intermediateView.frame = CGRectMake(50, 100, 48, 48);
    //intermediateView.frame = self.initialRect;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                         
        inView.alpha = 1;
     
    } completion:^(BOOL finished) {
         [intermediateView removeFromSuperview];
         if ([transitionContext transitionWasCancelled]) {
             [transitionContext completeTransition:NO];
         }
         else {
             [inView addSubview:toView];
             [fromView removeFromSuperview];
             [transitionContext completeTransition:YES];
         }
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
