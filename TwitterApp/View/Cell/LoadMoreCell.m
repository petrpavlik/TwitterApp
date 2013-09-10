//
//  LoadMoreCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/30/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadMoreCell.h"
#import "PersistentBackgroundColorView.h"

@interface LoadMoreCell ()

@property(nonatomic, strong) UIActivityIndicatorView* loadingIndicator;
@property(nonatomic, strong) UILabel* loadMoreLabel;
@property(nonatomic, strong) id textSizeChangedObserver;

@end

@implementation LoadMoreCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

- (void)setLoading:(BOOL)loading {
    
    _loading = loading;
    
    if (_loading) {
        
        _loadMoreLabel.hidden = YES;
        _loadingIndicator.hidden = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        
        _loadMoreLabel.hidden = NO;
        _loadingIndicator.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

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
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingIndicator.hidesWhenStopped = NO;
    [_loadingIndicator startAnimating];
    [contentView addSubview:_loadingIndicator];
    
    _loadMoreLabel = [UILabel new];
    _loadMoreLabel.text = @"Load more";
    [contentView addSubview:_loadMoreLabel];
    
    [_loadMoreLabel centerInSuperview];
    [_loadingIndicator centerInSuperview];
 
    [self setupFonts];
    
    __weak typeof(self) weakSelf = self;
    
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf setupFonts];
    }];
    
    PersistentBackgroundColorView* bottomSeparatorView = [[PersistentBackgroundColorView alloc] init];
    [bottomSeparatorView setPersistentBackgroundColor:[UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1]];
    bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomSeparatorView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-64-[bottomSeparatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomSeparatorView)]];
    
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorView(0.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomSeparatorView)]];
    
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:bottomSeparatorView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [contentView addConstraints:superviewConstraints];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.loadingIndicator startAnimating];
}

- (void)setupFonts {
    
    _loadMoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}



@end
