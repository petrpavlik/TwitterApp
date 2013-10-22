//
//  EmailCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "EmailFieldCell.h"

@interface EmailFieldCell () <UITextFieldDelegate>

@end

@implementation EmailFieldCell

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
    _textField.placeholder = @"Email";
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.returnKeyType = UIReturnKeyNext;
    _textField.delegate = self;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.keyboardType = UIKeyboardTypeEmailAddress;
    [_textField addTarget:self action:@selector(textFIeldDidChangeEditing) forControlEvents:UIControlEventEditingChanged];
    [contentView addSubview:_textField];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_textField]-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_textField)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField]|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(_textField)]];
}

- (BOOL)resignFirstResponder {
    
    [self.textField resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    [self.delegate emailFieldCellDidReturn:self];
    
    return NO;
}

- (void)textFIeldDidChangeEditing {
    [self.delegate emailFieldCell:self didChangeValue:self.textField.text];
}

@end
