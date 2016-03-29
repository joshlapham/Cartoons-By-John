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

@interface KJFavDoodlesListView ()

// Properties
@property (nonatomic, strong) NSArray *cellResults;
@property (nonatomic, strong) UIAlertController *noNetworkAlertView;

@end

@implementation KJFavDoodlesListView

- (NSArray *)returnDoodlesFavouriteArray {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by doodle date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageId"
                                                                   ascending:YES];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
        DDLogError(@"doodleStore: error fetching doodles: %@", [error localizedDescription]);
        return nil;
    }
    
    else {
        return fetchedObjects;
    }
}

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Doodles", @"Title of Doodles (drawings) favourites list view");
    
    [self.collectionView registerClass:[KJDoodleCell class]
            forCellWithReuseIdentifier:[KJDoodleCell cellIdentifier]];
    
    [self setupCollectionView];
    
    _cellResults = [self returnDoodlesFavouriteArray];
    
    // Check for Favourites results
    if ([_cellResults count] == 0) {
        [self kj_showthereAreNoFavouritesAlertWithTitle:self.title];
    }
    
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
