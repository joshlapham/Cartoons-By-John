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
    UIImageView *backgroundImageView;
    UITapGestureRecognizer *singleTap;
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
        //DDLogVerbose(@"found image in cache");
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback if image not in cache
    }
    
    [cell.doodleImageView setImageWithURL:[NSURL URLWithString:cellData.imageUrl]
                         placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType) {
                                    if (cellImage && !error) {
                                        DDLogVerbose(@"Doodles: fetched image");
                                    } else {
                                        DDLogError(@"Doodles: error fetching image: %@", [error localizedDescription]);
                                    }
    }];
    
    return cell;
}

#pragma mark - Data fetch did happen method

- (void)doodleFetchDidHappen
{
    DDLogVerbose(@"Doodles: data fetch did happen");
    
    // Check if coming from Favourites list ..
    if (selectedImageFromFavouritesList != nil) {
        // Is coming from favourites list
        randomImagesResults = [[NSArray alloc] initWithObjects:selectedImageFromFavouritesList, nil];
    } else {
        // Not coming from favourites list
        randomImagesResults = [[NSArray alloc] init];
        randomImagesResults = [KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES];
    }
    
    // Init action button in top right hand corner of navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActivityView)];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Set background of collectionView to nil to remove any network error image showing
    if (![backgroundImageView isHidden]) {
        [backgroundImageView removeFromSuperview];
        [self.collectionView setBackgroundView:nil];
    }
    
    // Remove tap gesture recognizer
    [self.collectionView removeGestureRecognizer:singleTap];
    
    // Reload collectionView data
    [self.collectionView reloadData];
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
        //DDLogVerbose(@"found image in cache");
        doodleImageToShare = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
    } else {
        //DDLogVerbose(@"no image in cache");
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
        DDLogVerbose(@"Doodles: network became available");
        
        // Dismiss no network UIAlertView
        [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
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
        // We have data, so call this method to fetch from local DB and reload table
        [self doodleFetchDidHappen];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [KJDoodleStore fetchDoodleData];
        }
        
    } else {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [KJDoodleStore fetchDoodleData];
        } else if ([JPLReachabilityManager isUnreachable]) {
            [self noNetworkConnection];
        }
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    } else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
        
        // Reload collectionView data to check for empty data source
        // TODO: maybe don't reload here?
        [self.collectionView reloadData];
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
    
    // Fetch doodle data
    [self fetchDataWithNetworkCheck];
    
    // Set background if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Image to use for background
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        backgroundImageView = [[UIImageView alloc] initWithImage:image];
        
        [self.collectionView addSubview:backgroundImageView];
        self.collectionView.backgroundView = backgroundImageView;
        self.collectionView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchDataWithNetworkCheck)];
        singleTap.numberOfTapsRequired = 1;
        [self.collectionView addGestureRecognizer:singleTap];
    }
    
    // Setup collection view
    [self setupCollectionView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    selectedImageFromFavouritesList = nil;
}

- (void)dealloc
{
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJDoodleDataFetchDidHappen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
