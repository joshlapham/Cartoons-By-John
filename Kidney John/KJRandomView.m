//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "MBProgressHUD.h"
#import "KJRandomImage.h"
#import "KJDoodleStore.h"
#import "KJDoodleCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KJRandomView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJRandomView {
    NSArray *randomImagesResults;
    NSString *currentRandomImageUrl;
    SDWebImageManager *webImageManager;
}

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
    
    [self.collectionView reloadData];
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
    randomImagesResults = [[NSArray alloc] init];
    randomImagesResults = [KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES];
    
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

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Doodles";
    
    // Init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJDoodleCell class] forCellWithReuseIdentifier:@"doodleCell"];
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading doodles ...";
    
    // Register for NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doodleFetchDidHappen)
                                                 name:@"KJDoodleDataFetchDidHappen"
                                               object:nil];
    
    // Use the doodleStore to fetch doodle data
    KJDoodleStore *store = [[KJDoodleStore alloc] init];
    [store fetchDoodleData];
    
    // Setup collection view
    [self setupCollectionView];
}

- (void)dealloc
{
    // Remove NSNotification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJDoodleDataFetchDidHappen" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Reload collectionView
    [self.collectionView reloadData];
}

@end
