//
//  PhotoController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 7/17/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "NetImageView.h"
#import "PhotoController.h"

@interface PhotoController () <UIScrollViewDelegate>

@property(nonatomic, strong) NetImageView* imageView;
@property(nonatomic, strong) UIScrollView* scrollView;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.tintColor = [UIColor whiteColor];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.minimumZoomScale=1.0;
    self.scrollView.maximumZoomScale=2.0;
    self.scrollView.contentSize= CGSizeMake(_scrollView.bounds.size.width+2, _scrollView.bounds.size.height+2);
    self.scrollView.contentOffset = CGPointMake(-1, -1);
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    
    self.imageView = [NetImageView new];
    self.imageView.contentMode = UIViewContentModeCenter;
    
    if (self.fullImageURL) {
        
        __weak typeof(self) weakSelf = self;
        
        [self.imageView setImageWithURL:self.fullImageURL placeholderImage:self.placeholderImage imageProcessingBlock:NULL completionBlock:^(NetImageView *imageView, NSError *error) {
            
            /*UIImage* image = imageView.image;
            imageView.image = weakSelf.placeholderImage;
            
            NSTimeInterval duration = 3;

            [UIView animateWithDuration:duration/2 animations:^{
                
                imageView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                imageView.image = image;
                
                [UIView animateWithDuration:duration/2 animations:^{
                    imageView.alpha = 1;
                }];
            }];*/
        }];
    }
    else {
        self.imageView.image = self.placeholderImage;
    }
    
    [self.scrollView addSubview:_imageView];
    
    //[self.imageView stretchInSuperview];
    self.imageView.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.imageView.backgroundColor = [UIColor redColor];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSelected)]];
    self.imageView.userInteractionEnabled = YES;
}

- (void)imageSelected {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = self.imageView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.scrollView.contentSize= CGSizeMake(_scrollView.bounds.size.width+2, _scrollView.bounds.size.height+2);
    [self scrollViewDidZoom:self.scrollView];
}

@end
