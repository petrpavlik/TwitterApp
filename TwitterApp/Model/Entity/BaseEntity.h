//
//  BaseEntity.h
//  Felixus
//
//  Created by Petr Pavlik on 12/30/12.
//  Copyright (c) 2012 uLikeIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* (^DictionaryToEntityKeyAdjusterBlock)(NSString* key);
typedef NSString* (^EntityToDictionaryKeyAdjusterBlock)(NSString* key);

@interface BaseEntity : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithJSONString:(NSString*)JSON;
- (NSDictionary*)dictionaryValue;
- (NSString*)JSONStringValue;

- (NSDate*)dateFromString:(NSString*)dateString;

@property(nonatomic, readonly) NSDictionary* classToDictionaryCustomMappings;

+ (void)setDictionaryToEntityKeyAdjusterBlock:(DictionaryToEntityKeyAdjusterBlock)block;
+ (void)setEntityToDictionaryKeyAdjusterBlock:(EntityToDictionaryKeyAdjusterBlock)block;

@end
