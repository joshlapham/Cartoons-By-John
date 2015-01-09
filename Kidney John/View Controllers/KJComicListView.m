//
//  KJComicListView.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicListView.h"
#import "KJComicCell.h"
#import "KJComicDetailView.h"
#import "KJComic.h"
#import "MBProgressHUD.h"
#import "KJComicStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "JPLReachabilityManager.h"
#import "UIFont+KJFonts.h"

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicListView {
    NSArray *comicResults;
    UIAlertView *noNetworkAlertView;
    MBProgressHUD *hud;
    UIImageView *backgroundImageView;
    UITapGestureRecognizer *singleTap;
}

#pragma mark - UICollectionView delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"Comix: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"comicDetailSegue" sender:self];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [comicResults count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    KJComic *cellData = [comicResults objectAtIndex:indexPath.row];

    // Set comic thumbnail using SDWebImage
    [cell.comicImageView sd_setImageWithURL:[NSURL fileURLWithPath:[KJComicStore returnThumbnailFilepathForComicObject:cellData]]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                              completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                  if (cellImage && !error) {
                                      DDLogVerbose(@"Comix: fetched comic thumbnail image from URL: %@", url);
                                  } else {
                                      DDLogError(@"Comix: error fetching comic thumbnail image: %@", [error localizedDescription]);
                                      // TODO: implement fallback
                                  }
                              }];
    
    return cell;
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        // Set this in every view controller so that the back button displays back instead of the root view controller name
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        KJComic *comicCell = [comicResults objectAtIndex:selectedIndexPath.row];
        
        destViewController.nameFromList = comicCell.comicName;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        // TODO: figure out a better way to pass data to dest VC rather than an array,
        // as this screws up segue from Favourites list
        // TODO: change this resultsArray for loading from filesystem
        destViewController.resultsArray = [NSArray arrayWithArray:comicResults];
        destViewController.collectionViewIndexFromList = selectedIndexPath;
        
        DDLogVerbose(@"Comix: selected comic row: %d", selectedIndexPath.row);
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Data fetch did happen method

- (void)comicFetchDidHappen
{
    DDLogVerbose(@"Comic fetch did happen ..");
    
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [hud hide:YES];
    
    // Set background of collectionView to nil to remove any network error image showing
    if (![backgroundImageView isHidden]) {
        [backgroundImageView removeFromSuperview];
        [self.collectionView setBackgroundView:nil];
    }
    
    // Remove tap gesture recognizer
    [self.collectionView removeGestureRecognizer:singleTap];
    
    // Reload collectionview with data just fetched on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange
{
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Comix: network became available");
        
        // Dismiss no network UIAlertView
        [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
        [KJComicStore fetchComicData];
    }
}

- (void)noNetworkConnection
{
    NSString *titleString = NSLocalizedString(@"No Network", @"Title of error alert displayed when no network connection is available");
    NSString *messageString = NSLocalizedString(@"This app requires a network connection", @"Error message displayed when no network connection is available");
    NSString *cancelButtonString = NSLocalizedString(@"Cancel", @"Title of Cancel button in No Network connection error alert");
    NSString *retryButtonString = NSLocalizedString(@"Retry", @"Title of Retry button in No Network connection error alert");
    
    noNetworkAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                    message:messageString
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonString
                                          otherButtonTitles:retryButtonString, nil];
    
    if (![KJComicStore hasInitialDataFetchHappened]) {
        
        // Hide progress
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [noNetworkAlertView show];
    }
}

- (void)fetchDataWithNetworkCheck
{
    // Show progress
    // Init MBProgressHUD
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    NSString *progressHudString = NSLocalizedString(@"Loading Comix ...", @"Message shown under progress wheel when comics are loading");
    hud.labelText = progressHudString;
    hud.labelFont = [UIFont kj_progressHudFont];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([KJComicStore hasInitialDataFetchHappened]) {
        // We have data, so call this method to fetch from local DB and reload table
        [self comicFetchDidHappen];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [KJComicStore fetchComicData];
        }
        
    } else {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [KJComicStore fetchComicData];
        } else if ([JPLReachabilityManager isUnreachable]) {
            [self noNetworkConnection];
        }
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogVerbose(@"Comix List: alert button clicked: %d", buttonIndex);
    
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
    
    self.title = NSLocalizedString(@"Comix", @"Title of Comics view");
    
    // Init collection view cell
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];
    
    // Register NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(comicFetchDidHappen)
                                                 name:KJComicDataFetchDidHappenNotification
                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Fetch comic data
    [self fetchDataWithNetworkCheck];
    
    // Set background image if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Image to use for table background
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
}

- (void)dealloc
{
    // Remove NSNotificationCenter observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KJComicDataFetchDidHappenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
