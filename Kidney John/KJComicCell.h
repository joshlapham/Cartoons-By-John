//
//  KJComicCell.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface KJComicCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *comicImageView;

- (void)setThumbImage:(NSString *)imageName;

@end
