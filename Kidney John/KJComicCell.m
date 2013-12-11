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

#pragma mark init methods
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.comicImageView = [[UIImageView alloc] init];
        self.comicImageView.frame = self.bounds;
        [self addSubview:self.comicImageView];
    }
    return self;
}

#pragma mark Set thumbnail method
- (void)setThumbImage:(NSString *)imageName
{
    self.comicImageView.image = [UIImage imageWithContentsOfFile:imageName];
}

@end
