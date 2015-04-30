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
#import "KJDoodleCell.h"
#import "KJRandomView.h"
#import "UIColor+KJColours.h"

// Constants
static NSString *kDoodleFavouriteCellIdentifier = @"DoodleFavouriteCell";

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
            forCellWithReuseIdentifier:kDoodleFavouriteCellIdentifier];
    
    // Setup collectionView
    [self setupCollectionView];
    
    // Init data source array
    // TODO: review this, init another way using Core Data
    _cellResults = [[KJDoodleStore sharedStore] returnFavouritesArray];
    
    // Check for Favourites results
    if ([_cellResults count] == 0) {
        [self thereAreNoFavourites];
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
    // Perform segue
    [self performSegueWithIdentifier:kSegueIdentifierDoodleDetail
                              sender:self];
}

#pragma mark UICollectionViewDataSource delegate methods

// TODO: refactor to own data source class

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
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
    return CGSizeMake(75, 75);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDoodleFavouriteCellIdentifier
                                                                                   forIndexPath:indexPath];
    
    // Init cell data
    KJRandomImage *cellData = [_cellResults objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

- (void)thereAreNoFavourites {
    // Init strings for noFavouritesAlertView
    NSString *titleString = NSLocalizedString(@"No Favourites", @"Title of error alert displayed when user hasn't favourited any items");
    NSString *messageString = NSLocalizedString(@"You haven't set any Doodles as favourites", @"Message displayed when user hasn't favourited any Doodles (drawings)");
    NSString *okButtonString = NSLocalizedString(@"OK", @"Title of OK button in No Favourites error alert");
    
    // Init alertView
    UIAlertController *noFavouritesAlertView = [UIAlertController alertControllerWithTitle:titleString
                                                                                   message:messageString
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions for alertView
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okButtonString
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           // Go back to previous view controller
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }];
    [noFavouritesAlertView addAction:okayAction];
    
    // Show alertView
    [self presentViewController:noFavouritesAlertView
                       animated:YES
                     completion:nil];
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierDoodleDetail]) {
        // Init destination view controller
        KJRandomView *destViewController = segue.destinationViewController;
        
        // Init cell data
        NSIndexPath *selectedIndex = [[self.collectionView indexPathsForSelectedItems] firstObject];
        KJRandomImage *doodleCell = [_cellResults objectAtIndex:selectedIndex.row];
        
        // Pass doodle to destination VC.
        // Destination VC then checks if selectedImage property is nil when it inits, and loads things appropriately.
        destViewController.selectedImageFromFavouritesList = doodleCell;
    }
}

@end
