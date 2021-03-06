//
//  KJVideoDataSource.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoDataSource.h"
#import "KJVideo.h"
#import "KJVideo+Methods.h"
#import "KJVideoCell.h"
#import "KJVideoCollectionViewCell.h"
#import <Parse/Parse.h>

@implementation KJVideoDataSource

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.cellDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[KJVideoCell cellIdentifier]
                                                        forIndexPath:indexPath];
    
    // Init cell data
    PFObject *cellData = [self.cellDataSource objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
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
    KJVideoCollectionViewCell *cell = (KJVideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[KJVideoCollectionViewCell cellIdentifier]
                                                                                                             forIndexPath:indexPath];
    
    // Init cell data
    PFObject *cellData = [self.cellDataSource objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

@end
