//
//  PhotoController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/17/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import "PhotoController.h"
#import "ImageScrollView.h"

@interface PhotoController ()

@property(nonatomic, strong) NetImageView* loadingImageView;
@property(nonatomic, weak) ImageScrollView* scrollView;

@end

@implementation PhotoController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:self.view.bounds];
    //scrollView.image = [UIImage imageNamed:@"CuriousFrog.jpg"];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    self.loadingImageView = [NetImageView new];
    
    if (self.fullImageURL) {
        
        scrollView.image = self.placeholderImage;
        
        __weak typeof(self) weakSelf = self;
        
        [self.loadingImageView setImageWithURL:self.fullImageURL placeholderImage:self.placeholderImage imageProcessingBlock:Nil completionBlock:^(NetImageView *imageView, NSError *error) {
            
            [weakSelf.scrollView setImage:imageView.image];
        }];
    }
    else {
        scrollView.image = self.placeholderImage;
    }
    
    UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDoubleTapped)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    UITapGestureRecognizer* singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSelected)];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
}

- (void)imageSelected {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)imageDoubleTapped {
    [self.scrollView handleDoubleTap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

@end
