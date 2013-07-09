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

- (NSOperation*)dataRequestOperationWithCursor:(NSString*)cursor completionBlock:(void (^)(NSArray *users, NSString* nextCursor, NSError *error))completionBlock {
    
    return [UserEntity requestFollowersOfUser:self.userId cursor:cursor completionBlock:completionBlock];
}

@end
