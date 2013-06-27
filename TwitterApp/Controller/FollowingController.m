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

- (NSOperation*)dataRequestOperation {
    
    __weak typeof(self) weakSelf = self;
    
    return [UserEntity requestFriendsOfUser:self.userId completionBlock:^(NSArray *friends, NSError *error) {
        
        if (error) {
            weakSelf.errorMessage = error.description;
        }
        else if (!friends.count) {
            weakSelf.errorMessage = @"No users found";
        }
        else {
            
            weakSelf.users = friends;
        }
    }];
}

@end
