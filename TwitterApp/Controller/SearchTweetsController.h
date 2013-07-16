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

@protocol SearchTweetsControllerDelegate <NSObject>

- (void)searchTweetsControllerDidSaveSearch:(SavedSearchEntity*)savedSearch;

@end

@interface SearchTweetsController : TweetsController

@property(nonatomic, weak) id <SearchTweetsControllerDelegate> delegate;
@property(nonatomic, strong) NSString* searchExpression;

@end
