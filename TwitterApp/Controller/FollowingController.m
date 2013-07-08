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

- (NSOperation*)dataRequestOperationWithCompletionBlock:(void (^)(NSArray *friends, NSString* nextCursor, NSError *error))completionBlock; {
    
    return [UserEntity requestFriendsOfUser:self.userId cursor:nil completionBlock:completionBlock];
}

@end
