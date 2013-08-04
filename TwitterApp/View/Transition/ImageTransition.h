//
//  ImageTransition.h
//  TwitterApp
//
//  Created by Petr Pavlik on 8/3/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageTransition : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property(nonatomic) CGRect initialRect;

@end
