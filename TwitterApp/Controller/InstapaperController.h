//
//  InstapaperController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^InstapaperSignInDidSucceedBlock)(void);

@interface InstapaperController : UITableViewController

@property(nonatomic, strong) NSURL* url;
@property(nonatomic, copy) InstapaperSignInDidSucceedBlock signInDidSucceedBlock;

@end
