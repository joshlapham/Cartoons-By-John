//
//  KJComicCell.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBaseCollectionViewCell.h"

@class KJComic;

@interface KJComicCell : KJBaseCollectionViewCell <UIScrollViewDelegate>

// Properties
@property (strong, nonatomic) UIImageView *comicImageView;

@end
