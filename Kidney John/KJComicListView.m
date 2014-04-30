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

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, SDWebImageManagerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicListView {
    NSMutableArray *comicImages;
    NSArray *comicThumbImages;
    NSArray *comicResults;
    NSMutableData *fileData;
    NSURL *fileUrl;
    SDWebImageManager *webImageManager;
    NSArray *comicFileResults;
    KJComicStore *comicStore;
    NSArray *dirArray;
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
    // loading from filesystem
    //NSString *comicFileName = [comicFileResults objectAtIndex:indexPath.row];
    
    // SDWebImage
    // check if image is in cache
    // DISABLED - loading from filesystem
//    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:comicCell.comicData]) {
//        //NSLog(@"found image in cache");
//    } else {
//        //NSLog(@"no image in cache");
//    }
    
//    otherHud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
//    otherHud.mode = MBProgressHUDModeAnnularDeterminate;
//    otherHud.backgroundColor = [UIColor clearColor];
    
//    [webImageManager downloadWithURL:[NSURL URLWithString:comicCell.comicData]
//                             options:0
//                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                //NSLog(@"video thumb download: %d of %d downloaded", receivedSize, expectedSize);
//                                //otherHud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
//                                //otherHud.progress = receivedSize / expectedSize;
//                            }
//                           completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//                               if (cellImage && finished) {
//                                   cell.comicImageView.image = cellImage;
//                                   [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//                                   //[otherHud hide:YES];
//                               } else {
//                                   NSLog(@"comic download error");
//                               }
//                           }];
    
    // end of loading from filesystem
    
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        //UIImage *comicImage = [comicStore returnComicImageFromComicObject:comicCell];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor whiteColor];
            cell.comicImageView.image = [comicStore returnComicThumbImageFromComicObject:comicCell];
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
    
    // TODO: add NSUserDefault here to say that first data fetch has completed
    
    // TODO: when to disable activity monitor and progress?
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Reload collectionview with data just fetched
    [[self collectionView] reloadData];
    //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
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
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading comix ...";
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Register NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(comicFetchDidHappen)
                                                 name:@"KJComicDataFetchDidHappen"
                                               object:nil];
    
    // Init comicStore and fetch comic data
    comicStore = [[KJComicStore alloc] init];
    [comicStore fetchComicData];
}

- (void)dealloc
{
    // Remove NSNotificationCenter observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJComicDataFetchDidHappen" object:nil];
}

@end
