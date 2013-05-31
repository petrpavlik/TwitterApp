//
//  LoadMoreCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/30/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "LoadMoreCell.h"

@interface LoadMoreCell ()

@property(nonatomic, strong) UIActivityIndicatorView* loadingIndicator;
@property(nonatomic, strong) UILabel* loadMoreLabel;

@end

@implementation LoadMoreCell

- (void)setLoading:(BOOL)loading {
    
    _loading = loading;
    
    if (_loading) {
        
        _loadMoreLabel.hidden = YES;
        [_loadingIndicator startAnimating];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        
        _loadMoreLabel.hidden = NO;
        [_loadingIndicator stopAnimating];
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
    [contentView addSubview:_loadingIndicator];
    
    _loadMoreLabel = [UILabel new];
    _loadMoreLabel.text = @"Load more";
    _loadMoreLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [contentView addSubview:_loadMoreLabel];
    
    [_loadMoreLabel centerInSuperview];
    [_loadingIndicator centerInSuperview];
    
}


@end
