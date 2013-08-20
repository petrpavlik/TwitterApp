//
//  LoadingCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/23/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView* contentView = self.contentView;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [activityIndicator startAnimating];
    activityIndicator.hidesWhenStopped = NO;
    [contentView addSubview:activityIndicator];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    //[superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[activityIndicator]" options:NSLayoutFormatAlignAllCenterX|NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(activityIndicator)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:contentView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0 
                                                                  constant:0]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];

    [contentView addConstraints:superviewConstraints];
}


@end
