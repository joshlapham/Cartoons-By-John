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
#import "UIFont+KJFonts.h"
#import "KJRandomImage.h"
#import "NSUserDefaults+KJSettings.h"

// Constants
static NSString *kDoodleCellIdentifier = @"doodleCell";

@interface KJRandomView () <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *randomImagesResults;
@property (nonatomic, strong) NSString *currentRandomImageUrl;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) UIAlertView *noNetworkAlertView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation KJRandomView

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJDoodleFetchDidHappenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = NSLocalizedString(@"Doodles", @"Title of Doodles (drawings) view");
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJDoodleCell class]
            forCellWithReuseIdentifier:kDoodleCellIdentifier];
    
    // Register for NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doodleFetchDidHappen)
                                                 name:KJDoodleFetchDidHappenNotification
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
        // Init image to use for background
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        
        // Add to background
        [self.collectionView addSubview:_backgroundImageView];
        self.collectionView.backgroundView = _backgroundImageView;
        self.collectionView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchDataWithNetworkCheck)];
        _singleTap.numberOfTapsRequired = 1;
        [self.collectionView addGestureRecognizer:_singleTap];
    }
    
    // Setup collection view
    [self setupCollectionView];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.selectedImageFromFavouritesList = nil;
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView {
    // Init flow layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // Use up whole screen (or frame)
    [flowLayout setItemSize:self.collectionView.bounds.size];
    
    // Set collectionView properties
    self.collectionView.pagingEnabled = YES;
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.frame = self.view.frame;
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_randomImagesResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDoodleCellIdentifier
                                                                                   forIndexPath:indexPath];
    
    // Init cell data
    KJRandomImage *cellData = [_randomImagesResults objectAtIndex:indexPath.row];
    
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

#pragma mark - Data fetch did happen method

- (void)doodleFetchDidHappen {
    DDLogVerbose(@"Doodles: data fetch did happen");
    
    // Check if coming from Favourites list ..
    // TODO: update this to use chosenDoodle property (or something -- there has to be a better way)
    if (self.selectedImageFromFavouritesList != nil) {
        // Is coming from favourites list
        _randomImagesResults = [[NSArray alloc] initWithObjects:self.selectedImageFromFavouritesList, nil];
    } else {
        // Not coming from favourites list
        _randomImagesResults = [[NSArray alloc] init];
        _randomImagesResults = [KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES];
    }
    
    // Init action button in top right hand corner of navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActivityView)];
    
    // Hide progress
    [_progressHud hide:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Set background of collectionView to nil to remove any network error image showing
    if (![_backgroundImageView isHidden]) {
        [_backgroundImageView removeFromSuperview];
        self.collectionView.backgroundView = nil;
    }
    
    // Remove tap gesture recognizer
    [self.collectionView removeGestureRecognizer:_singleTap];
    
    // Reload collectionView data
    [self.collectionView reloadData];
}

#pragma mark - UIActivityView methods

// TODO: refactor as per other UIActivities

- (void)showActivityView {
    // Get data for doodle currently on screen
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    KJRandomImage *cellData = [_randomImagesResults objectAtIndex:currentCellIndex.row];
    
    // TODO: review these image methods
    
    // Image to share
    UIImage *doodleImageToShare = [[UIImage alloc] init];
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        //DDLogVerbose(@"found image in cache");
        doodleImageToShare = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
    } else {
        //DDLogVerbose(@"no image in cache");
    }
    
    // Init UIActivity
    KJRandomFavouriteActivity *favouriteActivity = [[KJRandomFavouriteActivity alloc] initWithDoodle:cellData];
    
    // Init view controller for UIActivity
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[doodleImageToShare]
                                                                             applicationActivities:@[favouriteActivity]];
    
    // Set excluded activities for UIActivity
    activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList];
    
    // Present UIActivityController
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Reachability methods

- (void)noNetworkConnection {
    // Init strings for noNetworkAlertView
    NSString *titleString = NSLocalizedString(@"No Network", @"Title of error alert displayed when no network connection is available");
    NSString *messageString = NSLocalizedString(@"This app requires a network connection", @"Error message displayed when no network connection is available");
    NSString *cancelButtonString = NSLocalizedString(@"Cancel", @"Title of Cancel button in No Network connection error alert");
    NSString *retryButtonString = NSLocalizedString(@"Retry", @"Title of Retry button in No Network connection error alert");
    
    // Init alertView
    _noNetworkAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                    message:messageString
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonString
                                          otherButtonTitles:retryButtonString, nil];
    
    // Check if first doodle data fetch has happened
    if (![NSUserDefaults kj_hasFirstDoodleFetchCompletedSetting]) {
        // Hide progress
        [_progressHud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Show alertView
        [_noNetworkAlertView show];
    }
}

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Doodles: network became available");
        
        // Dismiss no network UIAlertView
        [_noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
        [[KJDoodleStore sharedStore] fetchDoodleData];
    }
}

- (void)fetchDataWithNetworkCheck {
    // Show progress
    // Init MBProgressHUD
    _progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHud.userInteractionEnabled = NO;
    NSString *progressHudString = NSLocalizedString(@"Loading Doodles ...", @"Message shown under progress wheel when doodles (drawings) are loading");
    _progressHud.labelText = progressHudString;
    _progressHud.labelFont = [UIFont kj_progressHudFont];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Check if first doodle data fetch has happened
    if (![NSUserDefaults kj_hasFirstDoodleFetchCompletedSetting]) {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [[KJDoodleStore sharedStore] fetchDoodleData];
        }
        else if ([JPLReachabilityManager isUnreachable]) {
            // Show noNetworkAlertView
            [self noNetworkConnection];
        }
    }
    else {
        // We have data, so call this method to fetch from local DB and reload table
        [self doodleFetchDidHappen];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [[KJDoodleStore sharedStore] fetchDoodleData];
        }
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    }
    else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
        
        // Reload collectionView data to check for empty data source
        // TODO: maybe don't reload here?
        [self.collectionView reloadData];
    }
}

@end
