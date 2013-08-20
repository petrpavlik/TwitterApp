//
//  SwitchCell.h
//  TwitterApp
//
//  Created by Petr Pavlik on 8/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void)switchCellDidToggleSwitch:(SwitchCell*)cell;

@end

@interface SwitchCell : UITableViewCell

@property(nonatomic, strong) UISwitch* valueSwitch;
@property(nonatomic, weak) id <SwitchCellDelegate> delegate;

@end
