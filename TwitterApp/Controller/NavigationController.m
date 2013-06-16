//
//  NavigationController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/31/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface NavigationController () <UIViewControllerRestoration>

@end

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.restorationIdentifier = @"jflskfdj";
    self.restorationClass = [self class];
    
    //self.view.layer.cornerRadius = 10;
    //self.view.clipsToBounds = YES;
}

#pragma mark -

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.viewControllers[0] forKey:@"RootViewController"];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    UIViewController* rootController = [coder decodeObjectForKey:@"RootViewController"];
    
    if (!rootController) {
        return nil;
    }
    
    return [[self alloc] initWithRootViewController:rootController];
}

@end
