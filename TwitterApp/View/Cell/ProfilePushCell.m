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
    
    self.tintColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
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
    
    UIImageView* separatorView = [[UIImageView alloc] initWithImage:skin.separatorImage];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:separatorView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:_mainLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:-1]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_mainLabel]->=8-[_valueLabel]-[disclosureImageView]-|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:NSDictionaryOfVariableBindings(_mainLabel, _valueLabel, disclosureImageView)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_mainLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:separatorView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [contentView addConstraints:superviewConstraints];
}

@end
