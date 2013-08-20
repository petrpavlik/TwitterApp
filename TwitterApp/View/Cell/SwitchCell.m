//
//  SwitchCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 8/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SwitchCell.h"
#import "AppDelegate.h"


@implementation SwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.valueSwitch = [[UISwitch alloc] init];
    self.valueSwitch.onTintColor = [skin navigationBarColor];
    self.accessoryView = self.valueSwitch;
    
    [self.valueSwitch addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)switchValueChanged {
    
    [self.delegate switchCellDidToggleSwitch:self];
}

@end
