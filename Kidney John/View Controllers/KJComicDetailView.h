//
//  KJComicDetailView.h
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KJComic;

@interface KJComicDetailView : UIViewController

@property (nonatomic, strong) NSIndexPath *collectionViewIndexFromList;
@property (nonatomic, strong) KJComic *initialComicToShow;

@end
