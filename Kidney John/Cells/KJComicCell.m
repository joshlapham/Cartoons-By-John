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

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Init imageView
        comicImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        // Make comic scale to fill view
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to view
        [self addSubview:comicImageView];
    }
    
    return self;
}

@end
