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
#import "DDLog.h"

// Set log level
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface KJFavDoodlesListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJFavDoodlesListView {
    NSArray *cellResults;
}

#pragma mark - UICollectionView delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"Doodle Favs: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"doodleDetailSegueFromFavourites" sender:self];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [cellResults count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 75);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DoodleFavouriteCell" forIndexPath:indexPath];
    
    KJRandomImage *cellData = [cellResults objectAtIndex:indexPath.row];
    // loading from filesystem
    //NSString *comicFileName = [comicFileResults objectAtIndex:indexPath.row];
    
    // SDWebImage
    // check if image is in cache
    // DISABLED - loading from filesystem
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
            //DDLogVerbose(@"found image in cache");
        cell.doodleImageView.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
        } else {
            //DDLogVerbose(@"no image in cache");
        }
    
//    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(defaultQueue, ^{
//        //UIImage *comicImage = [comicStore returnComicImageFromComicObject:comicCell];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.backgroundColor = [UIColor whiteColor];
//            cell.comicImageView.image = [comicStore returnComicThumbImageFromComicObject:comicCell];
//        });
//    });
    
    return cell;
}

#pragma mark - UIAlertView delegate methods

- (void)thereAreNoFavourites
{
    //DDLogVerbose(@"FAVOURITES: in thereAreNoFavourites method");
    NSString *messageString = [NSString stringWithFormat:@"You haven't set any %@ as favourites", @"Doodles"];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Favourites"
                                                 message:messageString
                                                delegate:self
                                       cancelButtonTitle:Nil
                                       otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    //DDLogVerbose(@"FAVOURITES: did dismiss no favourites alert view, popping Favourites List view");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Init collection view cell
    [self.collectionView registerClass:[KJDoodleCell class] forCellWithReuseIdentifier:@"DoodleFavouriteCell"];
    
    cellResults = [KJDoodleStore returnFavouritesArray];
    
    DDLogVerbose(@"cell results count: %d", [cellResults count]);
    
    if ([cellResults count] == 0) {
        [self thereAreNoFavourites];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"doodleDetailSegueFromFavourites"]) {
        KJRandomView *destViewController = segue.destinationViewController;
        NSIndexPath *selectedIndex = [[self.collectionView indexPathsForSelectedItems] firstObject];
        KJRandomImage *doodleCell = [cellResults objectAtIndex:selectedIndex.row];
        
        destViewController.selectedImageFromFavouritesList = doodleCell;
        //destViewController.startOn = [NSNumber numberWithInteger:indexPath.row];
    }

}

@end
