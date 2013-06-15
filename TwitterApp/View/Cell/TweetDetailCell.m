//
//  TweetDetailCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 6/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "PPLabel.h"
#import "TweetDetailCell.h"
#import "UIImage+TwitterApp.h"


@implementation TweetDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonSetup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.avatarImageView.image = nil;
}

- (void)commonSetup {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1]];
    [self setSelectedBackgroundView:bgColorView];
    
    UIView* contentView = self.contentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_avatarImageView.clipsToBounds = YES;
    //_avatarImageView.layer.cornerRadius = 5;
    [contentView addSubview:_avatarImageView];
    
    UIView* credentialsPlaceholder = [[UIView alloc] init];
    credentialsPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:credentialsPlaceholder];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [skin boldFontOfSize:16];
    _nameLabel.text = @"name";
    [credentialsPlaceholder addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _usernameLabel.font = [skin fontOfSize:15];
    _usernameLabel.text = @"username";
    _usernameLabel.textColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
    [credentialsPlaceholder addSubview:_usernameLabel];
    
    _tweetTextLabel = [[PPLabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    _tweetTextLabel.font = [skin fontOfSize:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    UIButton* numRetweetsButton = [UIButton new];
    numRetweetsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [numRetweetsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [numRetweetsButton setTitle:@"12" forState:UIControlStateNormal];
    [contentView addSubview:numRetweetsButton];
    
    UIButton* numFavoritesButton = [UIButton new];
    numFavoritesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [numFavoritesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [numFavoritesButton setTitle:@"12" forState:UIControlStateNormal];
    [contentView addSubview:numFavoritesButton];
    
    UIView* controlsView = [self createControlsView];
    controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:controlsView];
    
    NSMutableArray* credentialsPlaceholderConstraints = [NSMutableArray new];
    
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel][_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [credentialsPlaceholderConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_usernameLabel)]];
    
    [credentialsPlaceholder addConstraints:credentialsPlaceholderConstraints];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[credentialsPlaceholder]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, credentialsPlaceholder)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_avatarImageView]-10-[_tweetTextLabel]-10-[numRetweetsButton]-[controlsView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _tweetTextLabel, controlsView, numRetweetsButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_tweetTextLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[numRetweetsButton]-[numFavoritesButton]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numRetweetsButton, numFavoritesButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[controlsView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(controlsView)]];
    
    [contentView addConstraints:superviewConstraints];
}

#pragma mark -

- (UIView*)createControlsView {
    
    UIView* controlsView = [UIView new];
    
    UIButton* replyButton = [UIButton new];
    [replyButton setImage:[UIImage imageNamed:@"Icon-Retweet-Normal"] forState:UIControlStateNormal];
    [replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    replyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:replyButton];
    
    UIButton* retweetButton = [UIButton new];
    [retweetButton setImage:[UIImage imageNamed:@"Icon-Retweet-Normal"] forState:UIControlStateNormal];
    [retweetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    retweetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:retweetButton];
    
    UIButton* favoriteButton = [UIButton new];
    [favoriteButton setImage:[UIImage imageNamed:@"Icon-Retweet-Normal"] forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:favoriteButton];
    
    UIButton* otherButton = [UIButton new];
    [otherButton setImage:[UIImage imageNamed:@"Icon-Retweet-Normal"] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    otherButton.translatesAutoresizingMaskIntoConstraints = NO;
    [controlsView addSubview:otherButton];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[replyButton][retweetButton(replyButton)][favoriteButton(replyButton)][otherButton(replyButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[replyButton(44)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(replyButton)]];
    
    [controlsView addConstraints:superviewConstraints];
    
    return controlsView;
}

@end
