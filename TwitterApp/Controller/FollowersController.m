//
//  FollowersController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/27/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowersController.h"
#import "UserEntity.h"

@interface FollowersController ()

@end

@implementation FollowersController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.userId);
    
    self.title = @"Followers";
}

- (NSOperation*)dataRequestOperationWithCompletionBlock:(void (^)(NSArray *followers, NSString* nextCursor, NSError *error))completionBlock; {
    
    return [UserEntity requestFollowersOfUser:self.userId cursor:nil completionBlock:completionBlock];
}

@end
