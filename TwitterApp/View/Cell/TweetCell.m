//
//  TweetCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

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
    
    UIView* contentView = self.contentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.backgroundColor = [UIColor grayColor];
    [contentView addSubview:_avatarImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _nameLabel.text = @"name";
    [contentView addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_usernameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _usernameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
    _usernameLabel.text = @"username";
    [contentView addSubview:_usernameLabel];
    
    _tweetAgeLabel = [[UILabel alloc] init];
    _tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    _tweetTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    _tweetAgeLabel.text = @"1d";
    [contentView addSubview:_tweetAgeLabel];
    
    _tweetTextLabel = [[UILabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    _tweetTextLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    _mediaImageView = [[NetImageView alloc] init];
    _mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_mediaImageView.backgroundColor = [UIColor grayColor];
    _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    _mediaImageView.clipsToBounds = YES;
    [contentView addSubview:_mediaImageView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[_nameLabel]-[_usernameLabel]-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel, _usernameLabel, _tweetAgeLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel][_tweetTextLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mediaImageView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tweetTextLabel]-[_mediaImageView(300)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView, _tweetTextLabel)]];
    
    [contentView addConstraints:superviewConstraints];
    
}

#pragma mark -

+ (CGFloat)requiredHeightForTweetText:(NSString*)text {
    
    CGFloat textHeight = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:CGSizeMake(240, FLT_MAX)].height;
    
    CGFloat height = 10 + 16 + textHeight + 10;
    
    if (height < 70) {
        return 70;
    }
    else {
        return height;
    }
}

#pragma mark -

- (void)addURL:(NSURL*)url atRange:(NSRange)range {
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:
     [NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
}

@end
