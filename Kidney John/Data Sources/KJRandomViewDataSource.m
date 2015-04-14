//
//  KJRandomViewDataSource.m
//  Kidney John
//
//  Created by jl on 14/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJRandomViewDataSource.h"
#import "KJDoodleCell.h"
#import "KJRandomImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

// Constants
static NSString *kDoodleCellIdentifier = @"doodleCell";

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
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDoodleCellIdentifier
                                                                                   forIndexPath:indexPath];
    
    // Init cell data
    KJRandomImage *cellData = [self.cellDataSource objectAtIndex:indexPath.row];
    
    // SDWebImage
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        //DDLogVerbose(@"found image in cache");
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback if image not in cache
    }
    
    // Set doodle image
    [cell.doodleImageView sd_setImageWithURL:[NSURL URLWithString:cellData.imageUrl]
                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                       if (cellImage && !error) {
                                           DDLogVerbose(@"Doodles: fetched image from URL: %@", url);
                                       } else {
                                           DDLogError(@"Doodles: error fetching image: %@", [error localizedDescription]);
                                       }
                                   }];
    
    return cell;
}

@end
