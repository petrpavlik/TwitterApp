//
//  SearchFieldCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchFieldCell;

@protocol SearchFieldCellDelegate <NSObject>

- (void)searchFieldCellDidReturn:(SearchFieldCell*)cell;
- (void)searchFieldCell:(SearchFieldCell*)cell didChangeValue:(NSString*)value;

@end

@interface SearchFieldCell : UITableViewCell

@property(nonatomic, strong) UITextField* textField;
@property(nonatomic, weak) id <SearchFieldCellDelegate> delegate;

@end
