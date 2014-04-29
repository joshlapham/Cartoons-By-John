//
//  KJComicDetailCell.m
//  Kidney John
//
//  Created by jl on 29/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicDetailCell.h"

@implementation KJComicDetailCell

@synthesize comicImageView, comicScrollView;

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Register for NSNotifications
        NSString *notificationName = @"KJComicWasDoubleTapped";
        // Remove as observer first, just to be sure
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
        // Add as observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDoubleTap:) name:notificationName object:nil];
        
        // Init scroll view
        comicScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        comicScrollView.delegate = self;
        comicScrollView.minimumZoomScale = 1.0;
        comicScrollView.maximumZoomScale = 3.0;
        comicScrollView.contentSize = self.bounds.size;
        
        // Init image view
        comicImageView = [[UIImageView alloc] initWithFrame:comicScrollView.bounds];
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to scrollView
        [comicScrollView addSubview:comicImageView];
        // Add scrollView to view
        [self addSubview:comicScrollView];
    }
    return self;
}

- (void)dealloc
{
    NSString *notificationName = @"KJComicWasDoubleTapped";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return comicImageView;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    if(comicScrollView.zoomScale > comicScrollView.minimumZoomScale)
        [comicScrollView setZoomScale:comicScrollView.minimumZoomScale animated:YES];
    else
        [comicScrollView setZoomScale:comicScrollView.maximumZoomScale animated:YES];
    
}

@end
