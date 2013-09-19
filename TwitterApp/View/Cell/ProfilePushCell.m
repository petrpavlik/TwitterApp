//
//  ProfilePushCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/27/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfilePushCell.h"
#import "UIImage+TwitterApp.h"

@implementation ProfilePushCell

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
    
    self.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    UIView* contentView = self.contentView;

    _mainLabel = [UILabel new];
    _mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_mainLabel.font = [skin boldFontOfSize:16];
    _mainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _mainLabel.text = @"title";
    [contentView addSubview:_mainLabel];
    
    _valueLabel = [UILabel new];
    _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_valueLabel.font = [skin fontOfSize:16];
    _mainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _valueLabel.text = @"value";
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [_valueLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _valueLabel.textColor = self.tintColor;
    [contentView addSubview:_valueLabel];
    
    UIImageView* disclosureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Disclosure-Indocator"]];
    disclosureImageView.translatesAutoresizingMaskIntoConstraints = NO;
    disclosureImageView.image = [disclosureImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [contentView addSubview:disclosureImageView];
    
    UIView* separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:separatorView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_mainLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:-1]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_mainLabel]->=8-[_valueLabel]-[disclosureImageView]-|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:NSDictionaryOfVariableBindings(_mainLabel, _valueLabel, disclosureImageView)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[separatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    
    [contentView addConstraints:superviewConstraints];
}

@end
