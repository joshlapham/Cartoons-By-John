//
//  KJComicDetailView.h
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJComic.h"

@interface KJComicDetailView : UIViewController

@property (nonatomic, weak) NSString *nameFromList;
@property (nonatomic, weak) NSString *titleFromList;
@property (nonatomic, weak) NSString *fileNameFromList;
@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) NSIndexPath *collectionViewIndexFromList;
@property (nonatomic) BOOL isComingFromFavouritesList;

@end
