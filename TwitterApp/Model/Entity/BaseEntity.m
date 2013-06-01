//
//  BaseEntity.m
//  Felixus
//
//  Created by Petr Pavlik on 12/30/12.
//  Copyright (c) 2012 uLikeIT. All rights reserved.
//

#import "BaseEntity.h"
#import <objc/runtime.h>

DictionaryToEntityKeyAdjusterBlock dictionaryToEntityKeyAdjusterBlock;
EntityToDictionaryKeyAdjusterBlock entityToDictionaryKeyAdjusterBlock;

@implementation BaseEntity

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if((self = [super init]))
    {
        
        if (dictionaryToEntityKeyAdjusterBlock) {
            
            NSMutableDictionary* editedDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
            
            for (NSString* key in dictionary.allKeys) {
                
                NSString* capitalizedKey = dictionaryToEntityKeyAdjusterBlock(key);
                editedDictionary[capitalizedKey] = dictionary[key];
            }
            
            [self setValuesForKeysWithDictionary:editedDictionary];
        }
        else {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    return self;
}

- (id)initWithJSONString:(NSString*)JSON {
    
    NSError* error;
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[JSON dataUsingEncoding:NSUTF8StringEncoding] options:NULL error:&error];
    
    if (error || !dictionary) {
        return nil;
    }
    
    return [self initWithDictionary:dictionary];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // subclass implementation should set the correct key value mappings for custom keys
    //NSLog(@"%@ class: Undefined Key: %@", [self class], key);
}

- (NSDictionary*)dictionaryValue {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        
        if (value) {
            
            if ([value isKindOfClass:[BaseEntity class]]) {
                [dict setObject:[value dictionaryValue] forKey:[self keyAfterCustomMappingKey:key]];
            }
            else if ([value isKindOfClass:[NSArray class]]) {
                [dict setObject:[self arrayByEliminatingBaseEntitiesInArray:value] forKey:[self keyAfterCustomMappingKey:key]];
            }
            else {
                [dict setObject:value forKey:[self keyAfterCustomMappingKey:key]];
            }
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString*)JSONStringValue {
    
    NSDictionary* dictionary = self.dictionaryValue;
    
    if (![NSJSONSerialization isValidJSONObject:dictionary]) {
        return nil;
    }
    
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:NULL error:&error];
    
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSDate*)dateFromString:(NSString*)dateString {
    
    NSRange range = [dateString rangeOfString:@":" options:NSBackwardsSearch];
    dateString = [dateString stringByReplacingCharactersInRange:range withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZZZZ"];
    
    return [dateFormatter dateFromString:dateString];
}

- (NSArray*)arrayByEliminatingBaseEntitiesInArray:(NSArray*)array {
    
    NSMutableArray* editedArray = [[NSMutableArray alloc]initWithCapacity:array.count];
    
    for (id value in array) {
        
        if ([value isKindOfClass:[BaseEntity class]]) {
            [editedArray addObject:[value dictionaryValue]];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            [editedArray addObject:[self arrayByEliminatingBaseEntitiesInArray:value]];
        }
        else {
            [editedArray addObject:value];
        }
    }
    
    return editedArray;
}

- (NSString*)keyAfterCustomMappingKey:(NSString*)key {
    
    if (self.classToDictionaryCustomMappings[key]) {
        return self.classToDictionaryCustomMappings[key];
    }
    
    return key;
}

- (NSString*)description {
    
    NSString* selfAsString = self.dictionaryValue.description;
    //selfAsString = [selfAsString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //selfAsString = [selfAsString stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    return [NSString stringWithFormat:@"%@ : %@", [super description], selfAsString];
}

+ (void)setDictionaryToEntityKeyAdjusterBlock:(DictionaryToEntityKeyAdjusterBlock)block {
    
    dictionaryToEntityKeyAdjusterBlock = [block copy];
}

+ (void)setEntityToDictionaryKeyAdjusterBlock:(EntityToDictionaryKeyAdjusterBlock)block {
    
    entityToDictionaryKeyAdjusterBlock = [block copy];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSDictionary* selfAsDictionary = [decoder decodeObject];
    
    return [self initWithDictionary:selfAsDictionary];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    NSDictionary* selfAsDictionary = [self dictionaryValue];
    
    [encoder encodeRootObject:selfAsDictionary];
}

@end
