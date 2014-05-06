//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "MBProgressHUD.h"
#import "KJDoodleStore.h"
#import "KJDoodleCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KJRandomFavouriteActivity.h"
#import "Reachability.h"
#import "JPLReachabilityManager.h"

@interface KJRandomView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJRandomView {
    NSArray *randomImagesResults;
    NSString *currentRandomImageUrl;
    SDWebImageManager *webImageManager;
    MBProgressHUD *hud;
    UIAlertView *noNetworkAlertView;
}

@synthesize selectedImageFromFavouritesList;

#pragma mark - Setup collectionView method

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // Use up whole screen (or frame)
    [flowLayout setItemSize:self.collectionView.bounds.size];
    
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView setFrame:self.view.frame];
    
    //[self.collectionView reloadData];
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [randomImagesResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"doodleCell" forIndexPath:indexPath];
    
    KJRandomImage *cellData = [randomImagesResults objectAtIndex:indexPath.row];
    
    // SDWebImage
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        //NSLog(@"found image in cache");
    } else {
        //NSLog(@"no image in cache");
    }
    
    [cell.doodleImageView setImageWithURL:[NSURL URLWithString:cellData.imageUrl]
                         placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType) {
                                    if (cellImage && !error) {
                                        NSLog(@"Doodles: fetched image");
                                    } else {
                                        NSLog(@"Doodles: error fetching image: %@", [error localizedDescription]);
                                    }
    }];
    
    return cell;
}

#pragma mark - Preload image cache method

- (void)preloadCacheUsingIndexPath:(NSIndexPath *)currentIndexPath
{
    // add 1 to current index path row to get next object in randomImagesResults array
    // so that we can preload images before we swipe
    // TODO: change this so app doesn't crash when array goes out of bounds on last swipe
    KJRandomImage *doodleToCache = [randomImagesResults objectAtIndex:currentIndexPath.row+1];
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:doodleToCache.imageUrl]) {
        //NSLog(@"found image in cache");
    } else {
        //NSLog(@"no image in cache");
    }
    
    [webImageManager downloadWithURL:[NSURL URLWithString:doodleToCache.imageUrl]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                //NSLog(@"video thumb download: %d of %d downloaded", receivedSize, expectedSize);
                            }
                           completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                               if (cellImage && finished) {
                                   // NOTE we are not doing anything here, just loading into the cache
                                   //cell.doodleImageView.image = cellImage;
                                   NSLog(@"preloaded doodle: %@", doodleToCache.imageId);
                               } else {
                                   NSLog(@"doodle download error");
                               }
                           }];

}

#pragma mark - NSNotification method

- (void)doodleFetchDidHappen
{
    NSLog(@"Doodles: data fetch did happen");
    
    // Check if coming from Favourites list
    if (selectedImageFromFavouritesList != nil) {
        randomImagesResults = [[NSArray alloc] initWithObjects:selectedImageFromFavouritesList, nil];
        //NSLog(@"Doodles: results array count: %d", [randomImagesResults count]);
        //NSUInteger startOnIndex = [randomImagesResults indexOfObject:selectedImageFromFavouritesList];
        //NSLog(@"Doodles: start on image id: %@ and index: %d", selectedImageFromFavouritesList.imageId, startOnIndex);
    } else {
        // Not coming from favourites list
        //NSLog(@"Doodles: not coming from Favourites list");
        randomImagesResults = [[NSArray alloc] init];
        randomImagesResults = [KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES];
    }
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Reload collectionView data
    [self.collectionView reloadData];
}

#pragma mark - Return random image from an array

- (UIImage *)getRandomImageFromArray:(NSArray *)arrayToCheck
{
    NSString *stringToReturn = [[NSString alloc] init];
    UIImage *imageToReturn;
    
    // Get random URL if it wasn't just displayed
    do {
        // TODO: check if array is empty, error if so
        NSUInteger randomIndex = arc4random() % [arrayToCheck count];
        //stringToReturn = [NSString stringWithFormat:@"%@", [arrayToCheck objectAtIndex:randomIndex]];
        KJRandomImage *returnedRandomImage = [arrayToCheck objectAtIndex:randomIndex];
        stringToReturn = returnedRandomImage.imageUrl;
        imageToReturn = [UIImage imageWithData:returnedRandomImage.imageData];
    } while ([stringToReturn isEqualToString:currentRandomImageUrl]);
    
    // Set last URL variable to the URL string we're using
    currentRandomImageUrl = stringToReturn;
    
    return imageToReturn;
}

#pragma mark - UIActivityView methods

- (void)showActivityView
{
    // Get data for doodle currently on screen
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    KJRandomImage *cellData = [randomImagesResults objectAtIndex:currentCellIndex.row];
    
    // Image to share
    UIImage *doodleImageToShare;
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        //NSLog(@"found image in cache");
        doodleImageToShare = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
    } else {
        //NSLog(@"no image in cache");
    }
    
    // Init UIActivity
    NSString *titleString;
    
    if (![KJDoodleStore checkIfDoodleIsAFavourite:cellData.imageUrl]) {
        titleString = @"Add To Favourites";
    } else {
        titleString = @"Remove From Favourites";
    }
    
    KJRandomFavouriteActivity *favouriteActivity = [[KJRandomFavouriteActivity alloc] initWithActivityTitle:titleString andImageUrl:cellData.imageUrl];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[doodleImageToShare] applicationActivities:@[favouriteActivity]];
    activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList];
    
    // Present UIActivityController
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Reachability methods

- (void)noNetworkConnection
{
    noNetworkAlertView = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                 message:@"This app requires a network connection"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Retry", nil];
    
    if (![KJDoodleStore hasInitialDataFetchHappened]) {
        
        // Hide progress
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [noNetworkAlertView show];
    }
}

- (void)reachabilityDidChange
{
    if ([JPLReachabilityManager isReachable]) {
        NSLog(@"Doodles: network became available");
        [KJDoodleStore fetchDoodleData];
    }
}

- (void)fetchDataWithNetworkCheck
{
    // Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"Loading Doodles ...";
    hud.labelFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([KJDoodleStore hasInitialDataFetchHappened]) {
        [self doodleFetchDidHappen];
        // TODO: implement cache update
    } else {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [KJDoodleStore fetchDoodleData];
        } else if ([JPLReachabilityManager isUnreachable]) {
            // TODO: implement fallback if not reachable and is first data load
            [self noNetworkConnection];
        }
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button clicked: %d", buttonIndex);
    
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    } else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Doodles";
    
    // Init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJDoodleCell class] forCellWithReuseIdentifier:@"doodleCell"];
    
    // Init action button in top right hand corner of navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActivityView)];
    
    // Register for NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doodleFetchDidHappen)
                                                 name:@"KJDoodleDataFetchDidHappen"
                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Setup collection view
    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Fetch doodle data
    [self fetchDataWithNetworkCheck];
}

- (void)viewDidDisappear:(BOOL)animated
{
    selectedImageFromFavouritesList = nil;
}

- (void)dealloc
{
    // Remove NSNotification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJDoodleDataFetchDidHappen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
