//
//  TweetController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/26/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "TweetEntity.h"
#import "TweetController.h"

@interface TweetController () <UITextViewDelegate>

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
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:tweetController];
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return tweetController;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tweetTextView = [[UITextView alloc] init];
    _tweetTextView.delegate = self;
    _tweetTextView.font = [UIFont fontWithName:@"Helvetica" size:16];
    [self.view addSubview:_tweetTextView];
    [_tweetTextView stretchInSuperview];
    [_tweetTextView becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    self.title = @"140";
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.tweetToReplyTo) {
        _tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.tweetToReplyTo.user.screenName];
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

@end
