//
//  UserEntity.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "BaseEntity.h"
#import <Foundation/Foundation.h>

@interface UserEntity : BaseEntity

@property(nonatomic, strong) NSNumber* contributorsEnabled;
@property(nonatomic, strong) NSDate* createdAt;
@property(nonatomic, strong) NSNumber* defaultProfile;
@property(nonatomic, strong) NSNumber* defaultProfileImage;
@property(nonatomic, strong) NSString* description;
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
@property(nonatomic, strong) NSString* profileImageUrl;
@property(nonatomic, strong) NSNumber* protectedTweets;
@property(nonatomic, strong) NSString* screenName;
@property(nonatomic, strong) NSNumber* showAllInlineMedia;
@property(nonatomic, strong) NSNumber* statusesCount;
@property(nonatomic, strong) NSString* timeZone;
@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) NSNumber* utcOffset;
@property(nonatomic, strong) NSNumber* verified;

@end
