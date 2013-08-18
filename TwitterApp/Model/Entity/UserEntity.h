//
//  UserEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"
#import <Foundation/Foundation.h>

@class TweetEntity;

@interface UserEntity : BaseEntity

@property(nonatomic, strong) NSNumber* contributorsEnabled;
@property(nonatomic, strong) NSDate* createdAt;
@property(nonatomic, strong) NSNumber* defaultProfile;
@property(nonatomic, strong) NSNumber* defaultProfileImage;
@property(nonatomic, strong) NSDictionary* entities;
@property(nonatomic, strong) NSNumber* favouritesCount;
@property(nonatomic, strong) NSNumber* followRequestSent;
@property(nonatomic, strong) NSNumber* followersCount;
@property(nonatomic, strong) NSNumber* friendsCount;
@property(nonatomic, strong) NSNumber* geoEnabled;
@property(nonatomic, strong) NSString* userId;
@property(nonatomic, strong) NSNumber* isTranslator;
@property(nonatomic, strong) NSString* lang;
@property(nonatomic, strong) NSNumber* listedCount;
@property(nonatomic, strong) NSString* location;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* profileBannerUrl;
@property(nonatomic, strong) NSString* profileImageUrl;
@property(nonatomic, strong) NSNumber* protectedTweets;
@property(nonatomic, strong) NSString* screenName;
@property(nonatomic, strong) TweetEntity* status;
@property(nonatomic, strong) NSNumber* showAllInlineMedia;
@property(nonatomic, strong) NSNumber* statusesCount;
@property(nonatomic, strong) NSString* timeZone;
@property(nonatomic, strong) NSString* userDescription;
@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) NSNumber* utcOffset;
@property(nonatomic, readonly) NSNumber* verified;

@property(nonatomic, strong) NSString* expandedUserDescription;

+ (UserEntity*)currentUser;
+ (void)registerCurrentUser:(UserEntity*)user;

+ (NSOperation*)requestUserWithId:(NSString*)userId completionBlock:(void (^)(UserEntity* user, NSError* error))block;
+ (NSOperation*)requestUserWithScreenName:(NSString*)screenName completionBlock:(void (^)(UserEntity* user, NSError* error))block;
+ (NSOperation*)requestFollowersOfUser:(NSString*)userId cursor:(NSString*)cursor completionBlock:(void (^)(NSArray* followers, NSString* nextCursor, NSError* error))block;
+ (NSOperation*)requestFriendsOfUser:(NSString*)userId cursor:(NSString*)cursor completionBlock:(void (^)(NSArray* friends, NSString* nextCursor,  NSError* error))block;
- (NSOperation*)requestFriendshipStatusWithUser:(NSString*)userId completionBlock:(void (^)(NSNumber* following, NSNumber* followedBy, NSError* error))block;
- (NSOperation*)requestFollowingWithCompletionBlock:(void (^)(NSError* error))block;
- (NSOperation*)requestUnfollowingWithCompletionBlock:(void (^)(NSError* error))block;

+ (NSOperation*)searchUsersWithQuery:(NSString*)query count:(NSInteger)count page:(NSInteger)page completionBlock:(void (^)(NSArray* users, NSError* error))block;


@end
