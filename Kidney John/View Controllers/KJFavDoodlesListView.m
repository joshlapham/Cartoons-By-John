//
//  KJFavDoodlesListView.m
//  Kidney John
//
//  Created by jl on 6/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJFavDoodlesListView.h"
#import "KJRandomImage.h"
#import "KJDoodleStore.h"
#import "Kidney_John-Swift.h"
#import "UIColor+KJColours.h"
#import "UIViewController+KJUtils.h"
#import "Kidney_John-Swift.h"

// Constants
// collectionView insets (for all edges)
static CGFloat kCollectionViewEdgeInset = 20;

// collectionView cell size
static CGFloat kCollectionViewCellWidth = 75;
static CGFloat kCollectionViewCellHeight = 75;

// Segue identifiers
static NSString * kSegueIdentifierDoodleDetail = @"doodleDetailSegueFromFavourites";

@interface KJFavDoodlesListView ()

// Properties
@property (nonatomic, strong) NSArray *cellResults;
@property (nonatomic, strong) UIAlertController *noNetworkAlertView;

@end

@implementation KJFavDoodlesListView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = NSLocalizedString(@"Doodles", @"Title of Doodles (drawings) favourites list view");
    
    // Register cell with collectionView
    [self.collectionView registerClass:[KJDoodleCell class]
            forCellWithReuseIdentifier:[KJDoodleCell cellIdentifier]];
    
    // Setup collectionView
    [self setupCollectionView];
    
    // Init data source array
    // TODO: review this, init another way using Core Data
    _cellResults = [[KJDoodleStore sharedStore] returnFavouritesArray];
    
    // Check for Favourites results
    if ([_cellResults count] == 0) {
        [self kj_showthereAreNoFavouritesAlertWithTitle:self.title];
    }
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - Setup collectionView helper method

- (void)setupCollectionView {
    // Set collectionView properties
    // Accessibility
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        self.collectionView.backgroundColor = [UIColor kj_accessibilityDarkenColoursBackgroundColour];
    }
    
    else {
        self.collectionView.backgroundColor = [UIColor kj_viewBackgroundColour];
    }
}

#pragma mark - UICollectionView methods

#pragma mark - UICollectionViewDelegate methods

-   (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ImageStoryboard" bundle:nil];
    SingleImageViewController *destViewController = [storyboard instantiateViewControllerWithIdentifier:@"SingleImageViewController"];
    destViewController.hidesBottomBarWhenPushed = YES;
    
    // Init cell data
    KJRandomImage *cellData = [_cellResults objectAtIndex:indexPath.row];
    
    // Set image
    destViewController.imageToShow = cellData;
    
    // Push it
    [self.navigationController pushViewController:destViewController
                                         animated:YES];
}

#pragma mark UICollectionViewDataSource delegate methods

// TODO: refactor to own data source class

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCollectionViewEdgeInset, kCollectionViewEdgeInset, kCollectionViewEdgeInset, kCollectionViewEdgeInset);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [_cellResults count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kCollectionViewCellWidth, kCollectionViewCellHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[KJDoodleCell cellIdentifier]
                                                                                   forIndexPath:indexPath];
    
    // Init cell data
    KJRandomImage *cellData = [_cellResults objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

@end
