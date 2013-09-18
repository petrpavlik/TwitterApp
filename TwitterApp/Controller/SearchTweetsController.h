//
//  SearchController.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/13/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetsController.h"

@class SearchTweetsController;
@class SavedSearchEntity;

@interface SearchTweetsController : TweetsController

@property(nonatomic, strong) NSString* searchExpression;
@property(nonatomic) BOOL saveDisabled;

@end
