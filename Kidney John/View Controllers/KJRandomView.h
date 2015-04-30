//
//  KJRandomView.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KJRandomImage;

@interface KJRandomView : UICollectionViewController

// Properties
@property (nonatomic, strong) KJRandomImage *selectedImageFromFavouritesList;

@end
