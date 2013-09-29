//
//  ImageTransition.h
//  TwitterApp
//
//  Created by Petr Pavlik on 8/3/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ControllerDismissedBlock) (void);

@interface ImageTransition : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property(nonatomic) CGRect initialImageRect;
@property(nonatomic, strong) UIImage* image;
@property(nonatomic, copy) ControllerDismissedBlock controllerDismissedBlock;

@end
