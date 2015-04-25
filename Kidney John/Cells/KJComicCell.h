//
//  KJComicCell.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KJComic;

@interface KJComicCell : UICollectionViewCell <UIScrollViewDelegate>

// Properties
@property (strong, nonatomic) UIImageView *comicImageView;

// Methods
- (void)configureCellWithData:(KJComic *)cellData;
+ (NSString *)cellIdentifier;

@end
