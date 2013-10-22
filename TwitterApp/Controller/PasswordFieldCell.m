//
//  PasswordFieldCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "PasswordFieldCell.h"

@interface PasswordFieldCell () <UITextFieldDelegate>

@end

@implementation PasswordFieldCell

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
    _textField.placeholder = @"Password";
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.secureTextEntry = YES;
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
    
    [self.delegate passwordFieldCellDidReturn:self];
    
    return NO;
}

- (void)textFIeldDidChangeEditing {
    [self.delegate passwordFieldCell:self didChangeValue:self.textField.text];
}

@end
