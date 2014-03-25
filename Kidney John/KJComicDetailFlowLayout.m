//
//  KJComicDetailFlowLayout.m
//  Kidney John
//
//  Created by jl on 26/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicDetailFlowLayout.h"

@implementation KJComicDetailFlowLayout

- (id)init
{
    self = [super init];
    
    if (self) {
        //
    }
    return self;
}

//- (CGSize)collectionViewContentSize
//{
//    return self.collectionView.bounds.size;
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
