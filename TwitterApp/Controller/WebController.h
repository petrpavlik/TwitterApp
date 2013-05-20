//
//  WebController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebController : UIViewController

@property(nonatomic, strong) NSURL* url;

+ (WebController*)presentWithUrl:(NSURL*)url viewController:(UIViewController*)viewController;

@end
