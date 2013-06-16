//
//  TweetController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/26/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "TweetEntity.h"
#import "TweetController.h"

@interface TweetController () <UITextViewDelegate, UIViewControllerRestoration>

@property(nonatomic, strong) TweetEntity* tweetToReplyTo;
@property(nonatomic, strong) UITextView* tweetTextView;

@end

@implementation TweetController

+ (TweetController*)presentInViewController:(UIViewController*)viewController {
    return [TweetController presentAsReplyToTweet:nil inViewController:viewController];
}

+ (TweetController*)presentAsReplyToTweet:(TweetEntity*)tweet inViewController:(UIViewController*)viewController {

    TweetController* tweetController = [[TweetController alloc] init];
    
    if (tweet) {
        tweetController.tweetToReplyTo = tweet;
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    
    navigationController.viewControllers = @[tweetController];
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return tweetController;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = [[self class] description];
    self.restorationClass = [self class];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;

    _tweetTextView = [[UITextView alloc] init];
    _tweetTextView.delegate = self;
    _tweetTextView.restorationIdentifier = @"TweetTextTextView";
    _tweetTextView.font = [skin fontOfSize:16];
    [self.view addSubview:_tweetTextView];
    [_tweetTextView stretchInSuperview];
    [_tweetTextView becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    self.title = @"140";
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.tweetToReplyTo) {
        NSString* content = [NSString stringWithFormat:@"@%@ ", self.tweetToReplyTo.user.screenName];
        _tweetTextView.attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: [skin fontOfSize:16]}];
    }
}

#pragma mark -

- (void)done {
    
    [TweetEntity requestStatusUpdateWithText:self.tweetTextView.text asReplyToTweet:self.tweetToReplyTo.tweetId completionBlock:^(TweetEntity *tweet, NSError *error) {
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView {
    
    self.title = [NSString stringWithFormat:@"%d", 140 - textView.text.length];
    
    if (_tweetTextView.text.length > 0 && _tweetTextView.text.length <= 140) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark -

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.tweetTextView.attributedText forKey:@"TweetTextViewAttributedText"];
    
    if (self.tweetToReplyTo) {
        [coder encodeObject:self.tweetToReplyTo forKey:@"TweetToReplyTo"];
    }
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    NSAttributedString* content = [coder decodeObjectForKey:@"TweetTextViewAttributedText"];
    self.tweetTextView.attributedText = content;
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    TweetController* tweetController = [[TweetController alloc] init];
    tweetController.tweetToReplyTo = [coder decodeObjectForKey:@"TweetToReplyTo"];
    
    return tweetController;
}

@end
