//
//  ErrorCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/21/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "ErrorCell.h"

@implementation ErrorCell

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    _errorLabel = [UILabel new];
    _errorLabel.font = [skin fontOfSize:16];
    [self.contentView addSubview:_errorLabel];
    
    [_errorLabel centerInSuperview];
}

@end
