//
//  AbstractSkin.h
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractSkin : NSObject

- (void)applyGlobalAppearance;

- (UIFont*)fontOfSize:(CGFloat)size;
- (UIFont*)boldFontOfSize:(CGFloat)size;
- (UIFont*)lightFontOfSize:(CGFloat)size;

- (UIColor*)linkColor;
- (UIColor*)navigationBarColor;

@end
