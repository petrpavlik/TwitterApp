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
    
    _errorLabel = [UILabel new];
    _errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _errorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _errorLabel.textColor = [UIColor blackColor];
    _errorLabel.numberOfLines = 0;
    _errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_errorLabel];
    
    //[_errorLabel centerInSuperview];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_errorLabel]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_errorLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_errorLabel]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_errorLabel)]];
}

@end
