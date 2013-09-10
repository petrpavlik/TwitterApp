//
//  FollowTweetilusService.h
//  TwitterApp
//
//  Created by Petr Pavlik on 9/10/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FollowTweetilusService : NSObject

+ (FollowTweetilusService*)sharedInstance;

- (void)offerFollowingIfAppropriate;

@end
