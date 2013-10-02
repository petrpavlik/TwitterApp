//
//  WebControllerTransition.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/22/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "WebControllerTransition.h"

@interface WebControllerTransition ()

@property(nonatomic) BOOL alreadyTransitioned;

@end

@implementation WebControllerTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    //return 0.35;
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [fromVC view];
    UIView *toView = [toVC view];
    
    UIGraphicsBeginImageContextWithOptions(toView.bounds.size, YES, [UIScreen mainScreen].scale);
    [toView drawViewHierarchyInRect:toView.bounds afterScreenUpdates:YES];
    UIImage *toViewSnapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(fromView.bounds.size, YES, [UIScreen mainScreen].scale);
    [fromView drawViewHierarchyInRect:fromView.bounds afterScreenUpdates:YES];
    UIImage *fromViewSnapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (toView.bounds.size.width == fromView.bounds.size.height) {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        UIImageOrientation imageOrientation = UIImageOrientationUp;
        
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            imageOrientation = UIImageOrientationLeft;
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight) {
            imageOrientation = UIImageOrientationRight;
        }
        
        if (!self.alreadyTransitioned) {
            toViewSnapshot = [[UIImage alloc] initWithCGImage:toViewSnapshot.CGImage scale: 1.0 orientation: imageOrientation];
        }
        else {
            fromViewSnapshot = [[UIImage alloc] initWithCGImage:fromViewSnapshot.CGImage scale: 1.0 orientation: imageOrientation];
        }
    }
    
    
    // Add the snapshot view and animate its appearance
    UIImageView *intermediateView = nil;
    
    if (!self.alreadyTransitioned) {
        
        intermediateView = [[UIImageView alloc] initWithImage:toViewSnapshot];
        [inView addSubview:[[UIImageView alloc] initWithImage:fromViewSnapshot]];
    }
    else {
        
        intermediateView = [[UIImageView alloc] initWithImage:fromViewSnapshot];
        [inView addSubview:[[UIImageView alloc] initWithImage:toViewSnapshot]];
    }
    
    intermediateView.layer.shadowOffset = CGSizeMake(-1, 0);
    intermediateView.layer.shadowRadius = 5.0;
    intermediateView.layer.shadowColor = [UIColor blackColor].CGColor;
    intermediateView.layer.shadowOpacity = 0.5;
    
    //CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    //intermediateView.transform = transform;
    
    [inView addSubview:intermediateView];
    //inView.layer.shouldRasterize = YES;
    //inView.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    CGRect finalFrame = intermediateView.frame;
    CGRect initialFrame = intermediateView.frame;
    
    if (!self.alreadyTransitioned) {
        initialFrame.origin.x = initialFrame.size.width;
    }
    else {
        finalFrame.origin.x = initialFrame.size.width + 5; // + shadow
    }
    
    intermediateView.frame = initialFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        
        intermediateView.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        
        self.alreadyTransitioned = YES;
        
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
    
    /*[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        intermediateView.frame = finalFrame;
        
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
    }];*/
}

#pragma mark - Transitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


@end
