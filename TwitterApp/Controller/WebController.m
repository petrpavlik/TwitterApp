//
//  WebController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/20/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "WebController.h"
#import "UIActionSheet+TwitterApp.h"

@interface WebController () <UIWebViewDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) UIWebView* webView;
@property(nonatomic, weak) UIActivityIndicatorView* activityIndicator;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeSelected)];
    
    self.title = @"Loading...";
    
    if (self.url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backSelected)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardSelected)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadSelected)],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:Nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarksSelected)]];

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
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return webController;
}

#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.activityIndicator startAnimating];
    self.title = @"Loading...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"a" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"a" otherButtonTitles:@"Save to Pocket", "Open in Safari", "Save to Reading List", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
