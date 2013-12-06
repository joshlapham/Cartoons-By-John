//
//  KJComicCell.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicCell.h"

@implementation KJComicCell

@synthesize comicImage, imagesArray, comicImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.label = [[UILabel alloc] initWithFrame:self.bounds];
//        self.autoresizesSubviews = YES;
//        self.label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//        self.label.font = [UIFont boldSystemFontOfSize:42];
//        self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.adjustsFontSizeToFitWidth = YES;
//        
//        [self addSubview:self.label];
        
        // Image
        //self.comicImage = [[UIImage alloc] initWithContentsOfFile:@"baby.png"];
        //[self addSubview:self.comicImage];
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"baby.png"]];
        //UIImageView *imageView = [[UIImageView alloc] init];
        //imageView.frame = CGRectMake(5, 5, 5, 5);
        self.comicImageView = [[UIImageView alloc] init];
        self.comicImageView.frame = self.bounds;
        [self addSubview:self.comicImageView];
        
        //[self setNumber:0];
    }
    return self;
}

- (void)setThumbImage:(NSString *)imageName
{
    self.comicImageView.image = [UIImage imageWithContentsOfFile:imageName];
}

//- (void)setNumber:(NSInteger)number
//{
//    self.label.text = [NSString stringWithFormat:@"%d", number];
//    
//    //UIImage *cellImage = [UIImage imageNamed:@"baby.png"];
//    //self.comicImage = cellImage;
//}

@end
