//
//  KJComicDetailCell.m
//  Kidney John
//
//  Created by jl on 29/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicDetailCell.h"
#import "KJComic.h"
#import "KJComic+Methods.h"

// Constants
// Constant for NSNotification name
NSString * const KJComicWasDoubleTappedNotification = @"KJComicWasDoubleTapped";

@interface KJComicDetailCell ()

// Properties
@property (strong, nonatomic) UIImageView *comicImageView;
@property (strong, nonatomic) UIScrollView *comicScrollView;
@property (nonatomic, strong) NSString *comicTitle;

@end

@implementation KJComicDetailCell

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
        _comicScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _comicScrollView.delegate = self;
        _comicScrollView.minimumZoomScale = 1.0;
        _comicScrollView.maximumZoomScale = 3.0;
        _comicScrollView.contentSize = self.bounds.size;
        
        // Init imageView
        _comicImageView = [[UIImageView alloc] initWithFrame:_comicScrollView.bounds];
        _comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to scrollView
        [_comicScrollView addSubview:_comicImageView];
        
        // Add scrollView to view
        [self addSubview:_comicScrollView];
    }
    
    return self;
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _comicImageView;
}

#pragma mark - UIGestureRecognizer methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (_comicScrollView.zoomScale > _comicScrollView.minimumZoomScale) {
        [_comicScrollView setZoomScale:_comicScrollView.minimumZoomScale
                              animated:YES];
    }
    
    else {
        [_comicScrollView setZoomScale:_comicScrollView.maximumZoomScale
                              animated:YES];
    }
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJComic *cellData = (KJComic *)data;
    
    // Set comic title
    _comicTitle = cellData.comicName;
    
    // Set comic image
    _comicImageView.image = [cellData returnComicImageFromComic];
}

#pragma mark - Accessibility methods

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *accessibilityString = [NSString stringWithFormat:@"Comic title: %@",
                                     _comicTitle];
    
    return NSLocalizedString(accessibilityString, nil);
}

- (NSString *)accessibilityHint {
    return NSLocalizedString(@"Double-tap to zoom in or out on comic", nil);
}

@end
