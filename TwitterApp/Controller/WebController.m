//
//  WebController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import <AFNetworkActivityIndicatorManager.h>
#import <PocketAPI.h>
#import "NotificationView.h"
#import "WebController.h"
#import "UIActionSheet+TwitterApp.h"
#import "WebControllerTransition.h"

@interface WebController () <UIWebViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIWebView* webView;
@property(nonatomic, weak) UIActivityIndicatorView* activityIndicator;
@property(nonatomic, strong) UIBarButtonItem* goBackBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem* goForwardBarButtonItem;

@end

@implementation WebController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.url);
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator = activityIndicator;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(closeSelected)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-Back"] style:UIBarButtonItemStyleDone target:self action:@selector(closeSelected)];
    
    self.title = @"Loading...";
    
    if (self.url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    
    self.goBackBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Button-Toolbar-Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backSelected)];
    self.goBackBarButtonItem.enabled = NO;
    
    self.goForwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Button-Toolbar-Forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardSelected)];
    self.goForwardBarButtonItem.enabled = NO;
    
    self.toolbarItems = @[self.goBackBarButtonItem,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          self.goForwardBarButtonItem,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadSelected)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarksSelected)]];
    
    UISwipeGestureRecognizer* popSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popRequestedWithRecognizer:)];
    popSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    popSwipeRecognizer.delegate = self;
    
    [self.parentViewController.view addGestureRecognizer:popSwipeRecognizer];
    [_webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:popSwipeRecognizer];

}

- (void)closeSelected {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

+ (WebController*)presentWithUrl:(NSURL*)url viewController:(UIViewController*)viewController {
    
    WebController* webController = [[WebController alloc] init];
    webController.url = url;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    navigationController.viewControllers = @[webController];
    
    navigationController.navigationBar.translucent = YES;
    navigationController.toolbarHidden = NO;
    navigationController.toolbar.tintColor = [UIColor whiteColor];
    
    WebControllerTransition* webTransition = [WebControllerTransition new];
    navigationController.transitioningDelegate = webTransition;
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return webController;
}

#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.activityIndicator startAnimating];
    self.title = @"Loading...";
    
    self.goBackBarButtonItem.enabled = webView.canGoBack;
    self.goForwardBarButtonItem.enabled = webView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.goBackBarButtonItem.enabled = webView.canGoBack;
    self.goForwardBarButtonItem.enabled = webView.canGoForward;
}

#pragma mark -

- (void)backSelected {
    
    [self.webView goBack];
}

- (void)forwardSelected {
    
    [self.webView goForward];
}

- (void)reloadSelected {
    
    [self.webView reload];
}

- (void)bookmarksSelected {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Save to Pocket", @"Open in Safari", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==0) {
        
        if (self.webView.request.URL) {
            
            __weak typeof(self) weakSelf = self;
            
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            
            [[PocketAPI sharedAPI] saveURL:self.webView.request.URL handler: ^(PocketAPI *API, NSURL *URL, NSError *error) {
                
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                
                if (!weakSelf) {
                    
                    if (error) {
                        
                        [[LogService sharedInstance] logError:error];
                        [[[UIAlertView alloc] initWithTitle:nil message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:nil message:@"Link saved" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                        [[LogService sharedInstance] logEvent:@"link saved to Pocket" userInfo:Nil];
                    }
                    
                    return;
                }
                
                if (error) {
                    
                    [NotificationView showInView:self.view message:error.localizedRecoverySuggestion];
                } else {
                    
                    [NotificationView showInView:self.view message:@"Link saved to Pocket"];
                    [[LogService sharedInstance] logEvent:@"link saved to Pocket" userInfo:Nil];
                }
            }];
        }
    }
    else if (buttonIndex==1) {
        
        if (self.webView.request.URL) {
            [[UIApplication sharedApplication] openURL:self.webView.request.URL];
        }
    }
}

#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer locationInView:self.view].x < 20) {
        return YES;
    }
    
    return NO;
}

- (void)popRequestedWithRecognizer:(UIGestureRecognizer*)recognizer {
    
    NSLog(@"pop requested");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
