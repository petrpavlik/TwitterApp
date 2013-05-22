//
//  TweetCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "PPLabel.h"
#import "TweetCell.h"

@interface TweetCell () <PPLabelDelegate>

@property(nonatomic, strong) NSMutableDictionary* urlsDictonary;

@end

@implementation TweetCell

- (NSMutableDictionary*)urlsDictonary {
    
    if (!_urlsDictonary) {
        _urlsDictonary = [NSMutableDictionary new];
    }
    
    return _urlsDictonary;
}

#pragma mark -

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
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithWhite:200/255.0 alpha:1.0]];
    [self setSelectedBackgroundView:bgColorView];
    
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
    _usernameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
    _usernameLabel.text = @"username";
    [contentView addSubview:_usernameLabel];
    
    _retweetedLabel = [[UILabel alloc] init];
    _retweetedLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
    _retweetedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_retweetedLabel];
    
    _tweetAgeLabel = [[UILabel alloc] init];
    _tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    _tweetTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    _tweetAgeLabel.textColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1];
    _tweetAgeLabel.text = @"1d";
    [contentView addSubview:_tweetAgeLabel];
    
    _tweetTextLabel = [[PPLabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    _tweetTextLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    PPLabel* tweetTextLabel = (PPLabel*)_tweetTextLabel;
    tweetTextLabel.delegate = self;
    
    _mediaImageView = [[NetImageView alloc] init];
    _mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_mediaImageView.backgroundColor = [UIColor grayColor];
    _mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    _mediaImageView.clipsToBounds = YES;
    [contentView addSubview:_mediaImageView];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[_nameLabel]-[_usernameLabel]-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel, _usernameLabel, _tweetAgeLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-1-[_tweetTextLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mediaImageView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tweetTextLabel][_retweetedLabel]-[_mediaImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView, _tweetTextLabel, _retweetedLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarImageView]-[_retweetedLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _tweetTextLabel, _retweetedLabel)]];

    
    [contentView addConstraints:superviewConstraints];
    
}

#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.urlsDictonary removeAllObjects];
    _retweetedLabel.text = nil;
}

#pragma mark -

+ (CGFloat)requiredHeightForTweetText:(NSString*)text {
    
    CGFloat textHeight = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] constrainedToSize:CGSizeMake(240, FLT_MAX)].height;
    
    CGFloat height = 10 + 16 + 1 + textHeight + 10 + 2;
    
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
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.220 green:0.522 blue:0.686 alpha:1] range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.urlsDictonary[[NSValue valueWithRange:range]] = url;
}

#pragma mark -

- (BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:
             [NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
            
            self.tweetTextLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    return NO;
}

- (BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectURL:self.urlsDictonary[rangeValue]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, attributedString.length)];
    self.tweetTextLabel.attributedText = attributedString;
    
    return NO;
}

@end
