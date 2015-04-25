//
//  KJComicDetailCell.h
//  Kidney John
//
//  Created by jl on 29/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KJComic;

// Constants
extern NSString * const KJComicWasDoubleTappedNotification;

@interface KJComicDetailCell : UICollectionViewCell <UIScrollViewDelegate>

// Properties
@property (strong, nonatomic) UIImageView *comicImageView;
@property (strong, nonatomic) UIScrollView *comicScrollView;

// Methods
- (void)configureCellWithData:(KJComic *)cellData;
+ (NSString *)cellIdentifier;

@end
