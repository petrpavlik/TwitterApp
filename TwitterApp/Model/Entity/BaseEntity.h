//
//  BaseEntity.h
//  Base Entity
//
//  Created by Petr Pavlik on 12/30/12.
//  Copyright (c) 2012 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* (^DictionaryToEntityKeyAdjusterBlock)(NSString* key);
typedef NSString* (^EntityToDictionaryKeyAdjusterBlock)(NSString* key);

@interface BaseEntity : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithJSONString:(NSString*)JSON;
- (NSDictionary*)dictionaryValue;
- (NSString*)JSONStringValue;

@property(nonatomic, readonly) NSDictionary* classToDictionaryCustomMappings;

+ (void)setDictionaryToEntityKeyAdjusterBlock:(DictionaryToEntityKeyAdjusterBlock)block;
+ (void)setEntityToDictionaryKeyAdjusterBlock:(EntityToDictionaryKeyAdjusterBlock)block;

@end
