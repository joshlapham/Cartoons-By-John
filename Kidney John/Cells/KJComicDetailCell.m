//
//  KJComicDetailCell.m
//  Kidney John
//
//  Created by jl on 29/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicDetailCell.h"

// Constants
// Constant for NSNotification name
NSString * const KJComicWasDoubleTappedNotification = @"KJComicWasDoubleTapped";

@implementation KJComicDetailCell

@synthesize comicImageView, comicScrollView;

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJComicWasDoubleTappedNotification
                                                  object:nil];
}

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Register for NSNotifications
        // Remove as observer first, just to be sure
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:KJComicWasDoubleTappedNotification
                                                      object:nil];
        // Add as observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDoubleTap:)
                                                     name:KJComicWasDoubleTappedNotification
                                                   object:nil];
        
        // Init scrollView
        comicScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        comicScrollView.delegate = self;
        comicScrollView.minimumZoomScale = 1.0;
        comicScrollView.maximumZoomScale = 3.0;
        comicScrollView.contentSize = self.bounds.size;
        
        // Init imageView
        comicImageView = [[UIImageView alloc] initWithFrame:comicScrollView.bounds];
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to scrollView
        [comicScrollView addSubview:comicImageView];
        
        // Add scrollView to view
        [self addSubview:comicScrollView];
    }
    
    return self;
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return comicImageView;
}

#pragma mark - UIGestureRecognizer methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (comicScrollView.zoomScale > comicScrollView.minimumZoomScale) {
        [comicScrollView setZoomScale:comicScrollView.minimumZoomScale
                             animated:YES];
    }
    
    else {
        [comicScrollView setZoomScale:comicScrollView.maximumZoomScale
                             animated:YES];
    }
}

@end
