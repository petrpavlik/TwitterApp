//
//  ImageScrollView.m
//  TwitterApp
//
//  Created by Petr Pavlik on 9/7/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ImageScrollView.h"


@interface ImageScrollView () <UIScrollViewDelegate> {
    UIImageView *_zoomView;  // if tiling, this contains a very low-res placeholder image. otherwise it contains the full image.
    CGSize       _imageSize;
    
    CGPoint  _pointToCenterAfterResize;
    CGFloat  _scaleToRestoreAfterResize;
}

@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setImage:(UIImage *)image {

    NSParameterAssert(image);
    
    _image = image;
    
    [self displayImage:image];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    //_zoomView.frame = CGRectMake(0, 0, image.size.width*2, image.size.height*2);
    [self addSubview:_zoomView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    
    CGSize contentSize = imageSize;
    
    self.contentSize = contentSize;
    
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    //CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    CGFloat maxScale = 2.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    /*if (minScale > maxScale) {
        minScale = maxScale;
    }*/
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, _scaleToRestoreAfterResize));
    
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (void)handleDoubleTap {
    
    if(self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }
}

- (CGRect)frameOfZoomView {
    return _zoomView.frame;
}

@end

