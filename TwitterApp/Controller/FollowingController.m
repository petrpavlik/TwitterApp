//
//  FollowingController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/27/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "FollowingController.h"
#import "UserEntity.h"

@interface FollowingController ()

@end

@implementation FollowingController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.userId);
    
    self.title = @"Following";
}

- (NSOperation*)dataRequestOperationWithCursor:(NSString*)cursor completionBlock:(void (^)(NSArray *users, NSString* nextCursor, NSError *error))completionBlock {
    
    return [UserEntity requestFriendsOfUser:self.userId cursor:cursor completionBlock:completionBlock];
}

@end
