//
//  KJRandomViewDataSource.m
//  Kidney John
//
//  Created by jl on 14/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJRandomViewDataSource.h"
#import "KJRandomImage.h"
#import "Kidney_John-Swift.h"

@implementation KJRandomViewDataSource

#pragma mark - Init method

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cellDataSource = [NSArray new];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.cellDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[KJDoodleCell cellIdentifier]
                                                                                   forIndexPath:indexPath];
    
    // Init cell data
    KJRandomImage *cellData = [self.cellDataSource objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

@end
