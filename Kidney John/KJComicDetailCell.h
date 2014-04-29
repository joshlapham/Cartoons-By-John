//
//  KJComicDetailCell.h
//  Kidney John
//
//  Created by jl on 29/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJComicDetailCell : UICollectionViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *comicImageView;
@property (strong, nonatomic) UIScrollView *comicScrollView;

@end
