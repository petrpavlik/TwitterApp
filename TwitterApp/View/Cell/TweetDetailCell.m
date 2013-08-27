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
#import "PersistentBackgroundColorView.h"

@interface TweetDetailCell ()

@property(nonatomic, strong) id textSizeChangedObserver;
@property(nonatomic, strong) UIGestureRecognizer* cellLongPressGestureRecognizer;

@end

@implementation TweetDetailCell


- (void)commonSetup {

    
    UIView* contentView = self.contentView;
    
    self.avatarImageView = [[NetImageView alloc] init];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.opaque = YES;
    self.avatarImageView.tintColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    
    [contentView addSubview:self.avatarImageView];
    
    UITapGestureRecognizer* avatarTapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarSelected)];
    [self.avatarImageView addGestureRecognizer:avatarTapGestureRecongnizer];
    self.avatarImageView.userInteractionEnabled = YES;
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_nameLabel.font = [skin boldFontOfSize:16];
    self.nameLabel.text = @"name";
    [contentView addSubview:self.nameLabel];
    
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.usernameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    //_usernameLabel.font = [skin fontOfSize:15];
    self.usernameLabel.text = @"username";
    self.usernameLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:self.usernameLabel];
    
    self.retweetedButton = [[UIButton alloc] init];
    //_retweetedLabel.font = [skin fontOfSize:15];
    self.retweetedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.retweetedButton setTitleColor:[UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1] forState:UIControlStateNormal];
    //_retweetedButton.backgroundColor = [UIColor redColor];
    self.retweetedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.retweetedButton setImage:[[UIImage imageNamed:@"Icon-Retweeted-By"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.retweetedButton.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);
    self.retweetedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.retweetedButton.userInteractionEnabled = NO;
    self.retweetedButton.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    self.retweetedButton.hidden = YES;
    [contentView addSubview:self.retweetedButton];
    
    self.tweetAgeLabel = [[UILabel alloc] init];
    self.tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    //_tweetAgeLabel.font = [skin fontOfSize:15];
    self.tweetAgeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.tweetAgeLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    self.tweetAgeLabel.text = @"1d";
    [contentView addSubview:self.tweetAgeLabel];
    
    self.tweetTextLabel = [[PPLabel alloc] init];
    self.tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tweetTextLabel.numberOfLines = 0;
    self.tweetTextLabel.preferredMaxLayoutWidth = 240;
    //_tweetTextLabel.font = [skin fontOfSize:16];
    self.tweetTextLabel.text = @"blah blah";
    [contentView addSubview:self.tweetTextLabel];
    
    PPLabel* tweetTextLabel = (PPLabel*)self.tweetTextLabel;
    tweetTextLabel.delegate = self;
    
    self.mediaImageView = [[NetImageView alloc] init];
    self.mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaImageView.contentMode = UIViewContentModeCenter;
    self.mediaImageView.clipsToBounds = YES;
    self.mediaImageView.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:self.mediaImageView];
    
    self.locationLabel = [UILabel new];
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.locationLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:_locationLabel];
    
    self.createdWithLabel = [UILabel new];
    self.createdWithLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.createdWithLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [self.contentView addSubview:_createdWithLabel];
    
    UIView* quickAccessView = [self createQuickAccessView];
    quickAccessView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:quickAccessView];
    
    
    PersistentBackgroundColorView* separatorView = [[PersistentBackgroundColorView alloc] init];
    [separatorView setPersistentBackgroundColor:[UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1]];
    
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:separatorView];
    
    [self setupFonts];
    
    NetImageView* _avatarImageView = self.avatarImageView;
    UILabel* _nameLabel = self.nameLabel;
    UILabel* _usernameLabel = self.usernameLabel;
    UIButton* _retweetedButton = self.retweetedButton;
    UILabel* _tweetAgeLabel = self.tweetAgeLabel;
    UILabel* _tweetTextLabel = self.tweetTextLabel;
    NetImageView* _mediaImageView = self.mediaImageView;
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[_nameLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_nameLabel]-[_usernameLabel]->=8-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel, _tweetAgeLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[quickAccessView]-1-|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, quickAccessView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-1-[_tweetTextLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mediaImageView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tweetTextLabel]-[_mediaImageView(<=300)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_locationLabel]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_locationLabel, quickAccessView)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[quickAccessView(44)]-[_createdWithLabel]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_createdWithLabel, quickAccessView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tweetTextLabel(240)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarImageView]-[_retweetedButton]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _tweetTextLabel, _retweetedButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarImageView]-[_locationLabel]-[_createdWithLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _locationLabel, _createdWithLabel)]];
    
    [contentView addConstraints:superviewConstraints];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-64-[separatorView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(0.5)]-0.5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separatorView)]];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [contentView addGestureRecognizer:longPressRecognizer];
    self.cellLongPressGestureRecognizer = longPressRecognizer;
    
    __weak typeof(self) weakSelf = self;
    
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [weakSelf setupFonts];
    }];
    
}

- (void)setupFonts {
    [super setupFonts];
    
    _locationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _createdWithLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (CGFloat)requiredHeightForTweetText:(NSString *)text {
    
    return [TweetCell requiredHeightForTweetText:text] + [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline].pointSize + 5 + (44+8);
}

#pragma mark -

- (UIView*)createQuickAccessView {
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    UIView* quickAccessView = [UIView new];
    
    quickAccessView.tintColor = skin.linkColor;
    //quickAccessView.tintColor = [UIColor blackColor];
    
    UIButton* replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    replyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [replyButton addTarget:self action:@selector(replySelected) forControlEvents:UIControlEventTouchUpInside];
    [replyButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Reply"] forState:UIControlStateNormal];
    
    [quickAccessView addSubview:replyButton];
    
    UIButton* retweetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    retweetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [retweetButton addTarget:self action:@selector(retweetSelected) forControlEvents:UIControlEventTouchUpInside];
    [retweetButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Retweet"] forState:UIControlStateNormal];
    [quickAccessView addSubview:retweetButton];
    self.retweetButton = retweetButton;
    
    UIButton* favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [favoriteButton addTarget:self action:@selector(favoriteSelected) forControlEvents:UIControlEventTouchUpInside];
    [favoriteButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Favorite"] forState:UIControlStateNormal];
    [quickAccessView addSubview:favoriteButton];
    self.favoriteButton = favoriteButton;
    
    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [otherButton setImage:[UIImage imageNamed:@"Btn-Tweet-Detail-Other"] forState:UIControlStateNormal];
    [otherButton addTarget:self action:@selector(otherActionSelected) forControlEvents:UIControlEventTouchUpInside];
    otherButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quickAccessView addSubview:otherButton];
    
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[replyButton][retweetButton(replyButton)][favoriteButton(replyButton)][otherButton(replyButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[replyButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[retweetButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[favoriteButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[otherButton(>=44)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(replyButton, retweetButton, favoriteButton, otherButton)]];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:replyButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:quickAccessView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-1]];
    
    [quickAccessView addConstraints:superviewConstraints];
    
    return quickAccessView;
    
}


@end
