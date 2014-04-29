//
//  KJComicCell.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicCell.h"

@implementation KJComicCell

@synthesize comicImageView, comicScrollView;

//#pragma mark - Set thumbnail method
//
//- (void)setThumbImage:(NSString *)imageName
//{
//    self.comicImageView.image = [UIImage imageWithContentsOfFile:imageName];
//}

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // init scroll view
//        comicScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        comicScrollView.delegate = self;
//        comicScrollView.minimumZoomScale = 1.0;
//        comicScrollView.maximumZoomScale = 3.0;
//        [self addSubview:comicScrollView];
//        
//        comicImageView = [[UIImageView alloc] initWithFrame:comicScrollView.bounds];
//        [comicScrollView addSubview:comicImageView];
        
        comicImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        // NOTE: change this, for testing only
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:comicImageView];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return comicImageView;
}

@end
