//
//  SearchFieldCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "SearchFieldCell.h"

@implementation SearchFieldCell

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
    
    UIView* contentView = self.contentView;
    
    _textField = [UITextField new];
    _textField.placeholder = @"Search";
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_textField];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_textField]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_textField)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_textField)]];
}

- (BOOL)resignFirstResponder {
    
    [self.textField resignFirstResponder];
    
    return [super resignFirstResponder];
}

@end
