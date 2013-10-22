//
//  EmailCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmailFieldCell;

@protocol EmailFieldCellDelegate <NSObject>

- (void)emailFieldCellDidReturn:(EmailFieldCell*)cell;
- (void)emailFieldCell:(EmailFieldCell*)cell didChangeValue:(NSString*)value;

@end

@interface EmailFieldCell : UITableViewCell

@property(nonatomic, strong) UITextField* textField;
@property(nonatomic, weak) id <EmailFieldCellDelegate> delegate;


@end
