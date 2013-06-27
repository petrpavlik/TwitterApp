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

- (NSOperation*)dataRequestOperation {
    
    __weak typeof(self) weakSelf = self;
    
    return [UserEntity requestFollowersOfUser:self.userId completionBlock:^(NSArray *followers, NSError *error) {
        
        if (error) {
            weakSelf.errorMessage = error.description;
        }
        else if (!followers.count) {
            weakSelf.errorMessage = @"No followers found";
        }
        else {
            
            weakSelf.users = followers;
        }
    }];
}

@end
