//
//  KJComicCell.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicCell.h"

@implementation KJComicCell

@synthesize comicImageView;

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Init image view
        comicImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        // Make comic fill view
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        // Add imageView to view
        [self addSubview:comicImageView];
    }
    return self;
}

@end
