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
#import <Reachability.h>

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, SDWebImageManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicListView {
    NSArray *comicResults;
    SDWebImageManager *webImageManager;
    UIAlertView *noNetworkAlertView;
    MBProgressHUD *hud;
}

#pragma mark - UICollectionView delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"COMIX: selected item - %ld", (long)indexPath.row);
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
    
    KJComic *comicCell = [comicResults objectAtIndex:indexPath.row];
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        //UIImage *comicImage = [comicStore returnComicImageFromComicObject:comicCell];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor whiteColor];
            cell.comicImageView.image = [KJComicStore returnComicThumbImageFromComicObject:comicCell];
        });
    });
    
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
        
        NSLog(@"selected comic row: %d", selectedIndexPath.row);
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - NSNotification methods

- (void)comicFetchDidHappen
{
    NSLog(@"Comic fetch did happen ..");
    
    // TODO: init array here every time?
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES];
    
    // TODO: when to disable activity monitor and progress?
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Reload collectionview with data just fetched
    [[self collectionView] reloadData];
    //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

#pragma mark - Reachability methods

- (void)noNetworkConnection
{
    noNetworkAlertView = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                    message:@"This app requires a network connection"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Retry", nil];
    
    if (![KJComicStore hasInitialDataFetchHappened]) {
        [noNetworkAlertView show];
    }
}

- (void)fetchDataWithNetworkCheck
{
    // Reachability
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.parse.com"];
    reach.reachableBlock = ^(Reachability *reach) {
        NSLog(@"REACHABLE!");
        // Fetch new data
        [KJComicStore fetchComicData];
        
        // Hide any alert view that may be on screen
        [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        //[noNetworkAlertView removeFromSuperview];
    };
    
    reach.unreachableBlock = ^(Reachability *reach) {
        NSLog(@"UNREACHABLE!");
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([KJComicStore hasInitialDataFetchHappened]) {
                [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
                [self comicFetchDidHappen];
            } else {
                // Hide progress
                [hud hide:YES];
                
                // Hide network activity indicator
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                [self noNetworkConnection];
            }
        });
    };
    
    // Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading comix ...";
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([KJComicStore hasInitialDataFetchHappened]) {
        [self comicFetchDidHappen];
        // TODO: implement cache update
    } else {
        // Start the notifier
        [reach startNotifier];
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
    
    // Init comicStore and fetch comic data
    [self fetchDataWithNetworkCheck];
}

- (void)dealloc
{
    // Remove NSNotificationCenter observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJComicDataFetchDidHappen" object:nil];
}

@end
