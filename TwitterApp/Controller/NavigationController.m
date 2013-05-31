//
//  NavigationController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.layer.cornerRadius = 10;
    self.view.clipsToBounds = YES;
}

@end
