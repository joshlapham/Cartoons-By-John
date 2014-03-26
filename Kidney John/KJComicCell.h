//
//  KJComicCell.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJComicCell : UICollectionViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *comicImageView;
@property (strong, nonatomic) UIScrollView *comicScrollView;

//- (void)setThumbImage:(NSString *)imageName;

@end
