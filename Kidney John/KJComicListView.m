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

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, SDWebImageManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicListView {
    NSArray *comicResults;
    SDWebImageManager *webImageManager;
    UIAlertView *noNetworkAlertView;
    MBProgressHUD *hud;
    UIImageView *imageView;
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
    [cell.comicImageView setImageWithURL:[NSURL fileURLWithPath:[KJComicStore returnThumbnailFilepathForComicObject:cellData]]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                              completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType) {
                                  if (cellImage && !error) {
                                      DDLogVerbose(@"Comix: fetched comic thumbnail image");
                                  } else {
                                      DDLogError(@"Comix: error fetching comic thumbnail image: %@", [error localizedDescription]);
                                      // TODO: implement fallback
                                  }
                              }];
    
    return cell;
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        // Set this in every view controller so that the back button displays back instead of the root view controller name
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        KJComic *comicCell = [comicResults objectAtIndex:selectedIndexPath.row];
        // TODO: comicData is a string; use less misleading ivar names
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

#pragma mark - NSNotification methods

- (void)comicFetchDidHappen
{
    DDLogVerbose(@"Comic fetch did happen ..");
    
    // TODO: init array here every time?
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Set background of collectionView to nil to remove any network error image showing
    // TODO: should we be doing this every time?
    [imageView removeFromSuperview];
    self.collectionView.backgroundView = nil;
    
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
    noNetworkAlertView = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                    message:@"This app requires a network connection"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Retry", nil];
    
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
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"Loading Comix ...";
    hud.labelFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    
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
            // TODO: implement fallback if not reachable and is first data load
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
    }
}

#pragma mark - Check for empty UITableView data source

- (void)checkForEmptyDataSource
{
    // Check for empty data source
    DDLogVerbose(@"%s", __FUNCTION__);
    
    int sections = [self.collectionView numberOfSections];
    BOOL hasRows = NO;
    
    for (int i = 0; i < sections; i++) {
        hasRows = ([self.collectionView numberOfItemsInSection:i] > 0) ? YES: NO;
    }
    
    if (sections == 0 || hasRows == NO) {
        DDLogVerbose(@"Comix list data source is empty!");
        
        // TODO: remove title?
        
        // Image to use for table background
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        [self.collectionView addSubview:imageView];
        self.collectionView.backgroundView = imageView;
        self.collectionView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchDataWithNetworkCheck)];
        singleTap.numberOfTapsRequired = 1;
        [self.collectionView addGestureRecognizer:singleTap];
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Comix";
    
    // Init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    webImageManager.delegate = self;
    
    // Init collection view cell
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];
    
    // Register NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(comicFetchDidHappen)
                                                 name:@"KJComicDataFetchDidHappen"
                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Fetch comic data
    [self fetchDataWithNetworkCheck];
    
    // Check if data source for collectionView is empty
    [self checkForEmptyDataSource];
}

- (void)dealloc
{
    // Remove NSNotificationCenter observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJComicDataFetchDidHappen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
