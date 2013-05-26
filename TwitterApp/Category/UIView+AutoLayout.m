//
//  UIView+AutoLayout.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/23/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

- (void)centerInSuperview {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.superview
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0]];
}

- (void)stretchInSuperview {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

@end
