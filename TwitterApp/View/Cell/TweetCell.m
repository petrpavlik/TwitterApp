//
//  TweetCell.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "PPLabel.h"
#import "TweetCell.h"
#import "UIImage+TwitterApp.h"
#import "PersistentBackgroundColorView.h"

@interface TweetCell () <UIScrollViewDelegate>

@property(nonatomic, strong) UIGestureRecognizer* cellLongPressGestureRecognizer;
@property(nonatomic, strong) NSMutableDictionary* urlsDictonary;
@property(nonatomic, strong) NSMutableDictionary* hashtagsDictonary;
@property(nonatomic, strong) NSMutableDictionary* mentionsDictonary;
@property(nonatomic, strong) UIView* slidingContentView;

@property(nonatomic, strong) NSTimer* linkLongPressTimer;

@property(nonatomic, strong) UIScrollView* dummyScrollView;
@property(nonatomic, strong) UIView* quickAccessView;
@property(nonatomic, strong) UIView* panDetectView;

@property(nonatomic, strong) id textSizeChangedObserver;

@property(nonatomic, strong) NSArray* mediaImageHeightConstraints;

@end

@implementation TweetCell

- (NSMutableDictionary*)urlsDictonary {
    
    if (!_urlsDictonary) {
        _urlsDictonary = [NSMutableDictionary new];
    }
    
    return _urlsDictonary;
}

- (NSMutableDictionary*)hashtagsDictonary {
    
    if (!_hashtagsDictonary) {
        _hashtagsDictonary = [NSMutableDictionary new];
    }
    
    return _hashtagsDictonary;
}

- (NSMutableDictionary*)mentionsDictonary {
    
    if (!_mentionsDictonary) {
        _mentionsDictonary = [NSMutableDictionary new];
    }
    
    return _mentionsDictonary;
}

- (void)setRetweetedByUser:(BOOL)retweetedByUser {
    
    _retweetedByUser = retweetedByUser;
    self.retweetButton.selected = retweetedByUser;
}

- (void)setFavoritedByUser:(BOOL)favoritedByUser {
    
    _favoritedByUser = favoritedByUser;
    self.favoriteButton.selected = favoritedByUser;
}

#pragma mark -

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
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
    
    _dummyScrollView = [UIScrollView new];
    _dummyScrollView.pagingEnabled = YES;
    _dummyScrollView.delegate = self;
    _dummyScrollView.directionalLockEnabled = YES;
    [self.contentView addGestureRecognizer:_dummyScrollView.panGestureRecognizer];
    self.dummyScrollView.panGestureRecognizer.enabled = YES;
    
    _slidingContentView = [UIView new];
    _slidingContentView.frame = CGRectMake(0, 0, 320, 320); //dummy values to prevent crash on iOS 7 beta 2
    [self.contentView addSubview:_slidingContentView];
    
    UIView* contentView = _slidingContentView;
    
    _avatarImageView = [[NetImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.backgroundColor = [UIColor whiteColor];
    _avatarImageView.opaque = YES;
    _avatarImageView.tintColor = [UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1];
    //_avatarImageView.clipsToBounds = YES;
    //_avatarImageView.layer.cornerRadius = 5;
    
    [contentView addSubview:_avatarImageView];
    
    UITapGestureRecognizer* avatarTapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarSelected)];
    [_avatarImageView addGestureRecognizer:avatarTapGestureRecongnizer];
    _avatarImageView.userInteractionEnabled = YES;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow+1 forAxis:UILayoutConstraintAxisHorizontal];
    //_nameLabel.font = [skin boldFontOfSize:16];
    _nameLabel.text = @"name";
    [contentView addSubview:_nameLabel];
    
    _usernameLabel = [[UILabel alloc] init];
    _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_usernameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    //_usernameLabel.font = [skin fontOfSize:15];
    _usernameLabel.text = @"username";
    _usernameLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:_usernameLabel];
    
    _retweetedButton = [[UIButton alloc] init];
    //_retweetedLabel.font = [skin fontOfSize:15];
    _retweetedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_retweetedButton setTitleColor:[UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1] forState:UIControlStateNormal];
    //_retweetedButton.backgroundColor = [UIColor redColor];
    _retweetedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_retweetedButton setImage:[[UIImage imageNamed:@"Icon-Retweeted-By"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _retweetedButton.imageEdgeInsets = UIEdgeInsetsMake(1, 0, -1, 0);
    _retweetedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    _retweetedButton.userInteractionEnabled = NO;
    _retweetedButton.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    _retweetedButton.hidden = YES;
    [contentView addSubview:_retweetedButton];
    
    _tweetAgeLabel = [[UILabel alloc] init];
    _tweetAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetAgeLabel.textAlignment = NSTextAlignmentRight;
    //_tweetAgeLabel.font = [skin fontOfSize:15];
    _tweetAgeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _tweetAgeLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    _tweetAgeLabel.text = @"1d";
    [contentView addSubview:_tweetAgeLabel];
    
    _tweetTextLabel = [[PPLabel alloc] init];
    _tweetTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.preferredMaxLayoutWidth = 240;
    //_tweetTextLabel.font = [skin fontOfSize:16];
    _tweetTextLabel.text = @"blah blah";
    [contentView addSubview:_tweetTextLabel];
    
    PPLabel* tweetTextLabel = (PPLabel*)_tweetTextLabel;
    tweetTextLabel.delegate = self;
    
    _mediaImageView = [[NetImageView alloc] init];
    _mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _mediaImageView.contentMode = UIViewContentModeCenter;
    _mediaImageView.clipsToBounds = YES;
    _mediaImageView.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
    [contentView addSubview:_mediaImageView];
    
    UITapGestureRecognizer* mediaTapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaSelected)];
    [_mediaImageView addGestureRecognizer:mediaTapGestureRecongnizer];
    _mediaImageView.userInteractionEnabled = YES;

    
    _quickAccessView = [self createQuickAccessView];
    [self.contentView addSubview:_quickAccessView];
    
    //UIImageView* separatorView = [[UIImageView alloc] initWithImage:skin.separatorImage];
    
    PersistentBackgroundColorView* separatorView = [[PersistentBackgroundColorView alloc] init];
    [separatorView setPersistentBackgroundColor:[UIColor colorWithRed:0.784 green:0.784 blue:0.784 alpha:1]];
    
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:separatorView];
    
    _panDetectView = [UIView new];
    _panDetectView.backgroundColor = [UIColor clearColor];
    //[_panDetectView addGestureRecognizer:_dummyScrollView.panGestureRecognizer];
    //_panDetectView.userInteractionEnabled = NO;
    //[self.contentView addSubview:_panDetectView];
    
    [self setupFonts];
    
    NSMutableArray* superviewConstraints = [NSMutableArray new];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_avatarImageView(48)]-[_nameLabel]" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _nameLabel)]];
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_nameLabel]-[_usernameLabel(>=50)]->=8-[_tweetAgeLabel]-10-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _usernameLabel, _tweetAgeLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_avatarImageView(48)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-1-[_tweetTextLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mediaImageView]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tweetTextLabel]-[_mediaImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView, _tweetTextLabel)]];
    
    self.mediaImageHeightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_mediaImageView(0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)];
    [superviewConstraints addObjectsFromArray:self.mediaImageHeightConstraints];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_retweetedButton]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_retweetedButton)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tweetTextLabel(240)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tweetTextLabel)]];
    
    [superviewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_avatarImageView]-[_retweetedButton]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_avatarImageView, _tweetTextLabel, _retweetedButton)]];
    
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
    
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _usernameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _tweetAgeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _tweetTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _retweetedButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}


#pragma mark -

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.urlsDictonary removeAllObjects];
    [_retweetedButton setTitle:Nil forState:UIControlStateNormal];
    
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.origin.x = -50;
    self.contentView.frame = contentViewFrame;
    
    [self.urlsDictonary removeAllObjects];
    [self.hashtagsDictonary removeAllObjects];
    [self.mentionsDictonary removeAllObjects];
    
    self.dummyScrollView.contentOffset = CGPointMake(0, 0);
    
    self.avatarImageView.image = nil;
    
    self.retweetedButton.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect slidingContentViewFrame = self.contentView.bounds;
    slidingContentViewFrame.origin.x = MIN(-self.dummyScrollView.contentOffset.x, 0);
    _slidingContentView.frame = slidingContentViewFrame;
    
    CGRect quickAccessViewFrame = slidingContentViewFrame;
    quickAccessViewFrame.origin.x = slidingContentViewFrame.origin.x + slidingContentViewFrame.size.width;
    self.quickAccessView.frame = quickAccessViewFrame;
    
    self.panDetectView.frame = self.contentView.bounds;
    _dummyScrollView.frame = self.contentView.bounds;
    _dummyScrollView.contentSize = CGSizeMake(_dummyScrollView.frame.size.width*2, _dummyScrollView.frame.size.height-1);
    
    //UIScrollView* scrollView = (UIScrollView*)_slidingContentView.superview;
    //scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
}

#pragma mark -

+ (CGFloat)requiredHeightForTweetText:(NSString*)text {
    
    //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    //AbstractSkin* skin = appDelegate.skin;
    
    CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(240, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil].size.height;
    
    CGFloat height = 10 + [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize + 1 + textHeight + 10 + 5;
    
    if (height < 70) {
        return 70;
    }
    else {
        return height;
    }
}

#pragma mark -

- (void)addURL:(NSURL*)url atRange:(NSRange)range {
    
    NSParameterAssert(url);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.urlsDictonary[[NSValue valueWithRange:range]] = url;
}

- (void)addHashtag:(NSString*)hashtag atRange:(NSRange)range {
    
    NSParameterAssert(hashtag);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.hashtagsDictonary[[NSValue valueWithRange:range]] = hashtag;

}

- (void)addMention:(NSString*)mention atRange:(NSRange)range {
    
    NSParameterAssert(mention);
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:skin.linkColor range:range];
    
    self.tweetTextLabel.attributedText = attributedString;
    
    self.mentionsDictonary[[NSValue valueWithRange:range]] = mention;
    
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
            
            [self.linkLongPressTimer invalidate];
            self.linkLongPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(linkLongPressTimerDidFire:) userInfo:@{@"URL": self.urlsDictonary[rangeValue]} repeats:NO];
            
            self.cellLongPressGestureRecognizer.enabled = NO;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
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
    
    [self.linkLongPressTimer invalidate];
    self.linkLongPressTimer = nil;
    
    for (NSValue* rangeValue in self.urlsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectURL:self.urlsDictonary[rangeValue]];
            self.cellLongPressGestureRecognizer.enabled = YES;
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.hashtagsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectHashtag:self.hashtagsDictonary[rangeValue]];
            return YES;
        }
    }
    
    for (NSValue* rangeValue in self.mentionsDictonary.allKeys) {
        
        NSRange range = [rangeValue rangeValue];
        
        if (charIndex >= range.location && charIndex <= range.location+range.length) {
            
            NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
            [attributedString removeAttribute:NSUnderlineStyleAttributeName range:range];
            self.tweetTextLabel.attributedText = attributedString;
            
            [self.delegate tweetCell:self didSelectMention:self.mentionsDictonary[rangeValue]];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self.linkLongPressTimer invalidate];
    self.linkLongPressTimer = nil;
    
    NSMutableAttributedString* attributedString = [self.tweetTextLabel.attributedText mutableCopy];
    [attributedString removeAttribute:NSUnderlineStyleAttributeName range:NSMakeRange(0, attributedString.length)];
    self.tweetTextLabel.attributedText = attributedString;
    
    self.cellLongPressGestureRecognizer.enabled = YES;
    
    return NO;
}

#pragma mark -

- (void)replySelected {
    
    [self.delegate tweetCellDidRequestReply:self];
    [self cancelAccessViewAnimated];
}

- (void)retweetSelected {
    [self.delegate tweetCellDidRequestRetweet:self];
    [self cancelAccessViewAnimated];
}

- (void)favoriteSelected {
    [self.delegate tweetCellDidRequestFavorite:self];
    [self cancelAccessViewAnimated];
}

- (void)otherActionSelected {
    [self.delegate tweetCellDidRequestOtherAction:self];
    [self cancelAccessViewAnimated];
}

#pragma mark -

- (void)avatarSelected {
    [self.delegate tweetCellDidSelectAvatarImage:self];
}

- (void)mediaSelected {
    
    if (self.mediaImageView.image) {
        [self.delegate tweetCell:self didSelectImage:self.mediaImageView.image];
    }
}

- (void)linkLongPressTimerDidFire:(NSTimer*)timer {
    
    self.linkLongPressTimer = nil;
    
    PPLabel* textLabel = (PPLabel*)self.tweetTextLabel;
    [textLabel cancelCurrentTouch];
    
    [self.delegate tweetCell:self didLongPressURL:timer.userInfo[@"URL"]];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer*)gestureRecognizer {
    
    NSLog(@"%@", gestureRecognizer);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate tweetCellDidLongPress:self];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x!=0) {
        
        [self setSelected:NO animated:YES];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.delegate tweetCellDidScrollHorizontally:self];
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    CGRect slidingContentViewFrame = self.slidingContentView.frame;
    slidingContentViewFrame.origin.x = MIN(-scrollView.contentOffset.x, 0);
    self.slidingContentView.frame = slidingContentViewFrame;
    
    CGRect quickAccessViewFrame = self.quickAccessView.frame;
    quickAccessViewFrame.origin.x = slidingContentViewFrame.origin.x + slidingContentViewFrame.size.width;
    self.quickAccessView.frame = quickAccessViewFrame;
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

#pragma mark -

- (void)cancelAccessViewAnimated {
    
    CGRect slidingContentViewFrame = self.slidingContentView.frame;
    CGRect quickAccessViewFrame = self.quickAccessView.frame;
    
    slidingContentViewFrame.origin.x = 0;
    quickAccessViewFrame.origin.x = slidingContentViewFrame.size.width;
    
    self.dummyScrollView.panGestureRecognizer.enabled = NO;
    
    [UIView animateWithDuration:self.contentView.frame.size.width*0.001 animations:^{
        
        self.slidingContentView.frame = slidingContentViewFrame;
        self.quickAccessView.frame = quickAccessViewFrame;
        
    } completion:^(BOOL finished) {
        self.dummyScrollView.contentOffset = CGPointMake(0, self.dummyScrollView.contentOffset.y);
        self.dummyScrollView.panGestureRecognizer.enabled = YES;
    }];
}

- (void)setMediaImageHeight:(CGFloat)height {
    
    UIView* contentView = _slidingContentView;
    
    [contentView removeConstraints:self.mediaImageHeightConstraints];
    
    self.mediaImageHeightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_mediaImageView(%f)]", height] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mediaImageView)];
    
    [contentView addConstraints:self.mediaImageHeightConstraints];
}

@end
