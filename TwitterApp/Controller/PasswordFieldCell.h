//
//  PasswordFieldCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PasswordFieldCell;

@protocol PasswordFieldCellDelegate <NSObject>

- (void)passwordFieldCellDidReturn:(PasswordFieldCell*)cell;
- (void)passwordFieldCell:(PasswordFieldCell*)cell didChangeValue:(NSString*)value;

@end

@interface PasswordFieldCell : UITableViewCell

@property(nonatomic, strong) UITextField* textField;
@property(nonatomic, weak) id <PasswordFieldCellDelegate> delegate;

@end
