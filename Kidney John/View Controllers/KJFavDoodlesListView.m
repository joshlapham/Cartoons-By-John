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
#import <SDWebImage/UIImageView+WebCache.h>
#import "KJRandomView.h"

// Constants
static NSString *kDoodleFavouriteCellIdentifier = @"DoodleFavouriteCell";

@interface KJFavDoodlesListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellResults;

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

#pragma mark - UICollectionView delegate methods

-   (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    DDLogVerbose(@"Doodle Favs: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"doodleDetailSegueFromFavourites" sender:self];
}

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
    
    // SDWebImage
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        cell.doodleImageView.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: fallback if no image in cache
    }
    
    return cell;
}

- (void)thereAreNoFavourites {
    // Init strings for noFavouritesAlertView
    NSString *titleString = NSLocalizedString(@"No Favourites", @"Title of error alert displayed when user hasn't favourited any items");
    NSString *messageString = NSLocalizedString(@"You haven't set any Doodles as favourites", @"Message displayed when user hasn't favourited any Doodles (drawings)");
    NSString *okButtonString = NSLocalizedString(@"OK", @"Title of OK button in No Favourites error alert");
    
    // Init alertView
    UIAlertView *noFavouritesAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                 message:messageString
                                                delegate:self
                                       cancelButtonTitle:Nil
                                       otherButtonTitles:okButtonString, nil];
    
    // Show alertView
    [noFavouritesAlertView show];
}

#pragma mark - UIAlertView delegate methods

-       (void)alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    // Go back to previous view controller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"doodleDetailSegueFromFavourites"]) {
        KJRandomView *destViewController = segue.destinationViewController;
        NSIndexPath *selectedIndex = [[self.collectionView indexPathsForSelectedItems] firstObject];
        KJRandomImage *doodleCell = [_cellResults objectAtIndex:selectedIndex.row];
        destViewController.selectedImageFromFavouritesList = doodleCell;
    }
}

@end
