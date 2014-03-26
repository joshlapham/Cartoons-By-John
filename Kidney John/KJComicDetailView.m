//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"
#import "MBProgressHUD.h"
#import "KJComicCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KJComicDetailFlowLayout.h"
#import "KJComicStore.h"

@interface KJComicDetailView () <UIActionSheetDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicDetailView {
    float expectedLength;
    float currentLength;
    SDWebImageManager *webImageManager;
    KJComicStore *comicStore;
    UIScrollView *comicScrollView;
}

@synthesize nameFromList, titleFromList, fileNameFromList, hud, resultsArray, collectionViewIndexFromList, isComingFromFavouritesList;

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"count for coll. view - %d", [self.resultsArray count]);
    return [[self resultsArray] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicDetailCell" forIndexPath:indexPath];
    
    KJComic *cellData = [self.resultsArray objectAtIndex:indexPath.row];
    
    // set title to comic
    // TODO: title to be set only after cell has finished loading
    self.title = cellData.comicName;
    
    // update titleFromList so that Favourites will function correctly,
    // as our Favourites methods use this ivar
    titleFromList = cellData.comicName;
    
    //NSLog(@"comic name: %@", cellData.comicName);
    //NSLog(@"cell for item results array count: %d", [self.resultsArray count]);

    // DISABLED cache for local filesystem loading
//    // SDWebImage
//    // check if image is in cache
//    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.comicData]) {
//        //NSLog(@"found image in cache");
//    } else {
//        //NSLog(@"no image in cache");
//    }
//    
//    [webImageManager downloadWithURL:[NSURL URLWithString:cellData.comicData]
//                             options:0
//                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                //NSLog(@"video thumb download: %d of %d downloaded", receivedSize, expectedSize);
//                            }
//                           completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//                               if (cellImage && finished) {
//                                   cell.comicImageView.image = cellImage;
//                                   cell.comicImageView.tag = 101;
//                               } else {
//                                   NSLog(@"comic download error");
//                               }
//                           }];
    
    cell.comicImageView.image = [comicStore returnComicImageFromComicObject:cellData];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - setup collection view method

- (void)setupCollectionView
{
    //[self.collectionView.collectionViewLayout invalidateLayout];
    //[self.collectionView setBounds:self.view.bounds];
    [self.collectionView setFrame:self.view.bounds];
    
    KJComicDetailFlowLayout *flowLayout = [[KJComicDetailFlowLayout alloc] init];
    //UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // use up whole screen (or frame)
    [flowLayout setItemSize:self.collectionView.bounds.size];
    
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setClipsToBounds:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    //[self.collectionView.collectionViewLayout invalidateLayout];
    
    //[self.collectionView reloadData];
}

#pragma mark - UIActionSheet delegate methods

- (void)showActionSheet:(id)sender
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    //NSString *other2 = @"Share on Facebook";
    //NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    //NSString *actionSheetTitle = @"Action";
    //NSString *destructiveTitle = @"Destructive button";
    
    // Set Favourites button text accordingly
    // TODO: use better ivar name for titleFromList
    if (![comicStore checkIfComicIsAFavourite:titleFromList]) {
        favouritesString = @"Add to Favourites";
    } else {
        favouritesString = @"Remove from Favourites";
    }
    
    // Init action sheet with Favourites and Share buttons
    // NOTE - no FB/Twitter share is enabled for Comics right now
    //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, other2, other3, nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, nil];
    
    // Add action sheet to view, taking in consideration the tab bar
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        [comicStore updateComicFavouriteStatus:titleFromList isFavourite:YES];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        [comicStore updateComicFavouriteStatus:titleFromList isFavourite:NO];
    } else if ([buttonPressed isEqualToString:@"Share on Twitter"]) {
        NSLog(@"ACTION SHEET: share on twitter button pressed");
        //[self postToTwitter];
    } else if ([buttonPressed isEqualToString:@"Share on Facebook"]) {
        NSLog(@"ACTION SHEET: share on facebook button pressed");
        //[self postToFacebook];
    }
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // comicImageView tag is 101
    return [self.collectionView viewWithTag:101];
}

#pragma mark - ScrollView methods

- (void)centerScrollViewContents {
    CGSize boundsSize = comicScrollView.bounds.size;
    CGRect contentsFrame = [[self.collectionView viewWithTag:101] frame];
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    [[self.collectionView viewWithTag:101] setFrame:contentsFrame];
}

#pragma mark - Gesture recognizer methods

- (void)comicWasDoubleTapped
{
    NSLog(@"comic was double tapped");
    
    // Navbar
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
    
    // refresh collection view cell bounds
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init scroll view
    comicScrollView = [[UIScrollView alloc] initWithFrame:self.collectionView.frame];
    comicScrollView.delegate = self;
    //[self centerScrollViewContents];
    comicScrollView.minimumZoomScale = 1.0;
    comicScrollView.maximumZoomScale = 3.0;
    //comicScrollView.contentSize = self.collectionView.bounds.size;
    [self.view addSubview:comicScrollView];
    [comicScrollView addSubview:self.collectionView];
    
    // DEBUGGING
    NSLog(@"CDV: row: %d", collectionViewIndexFromList.row);
    // END OF DEBUGGING
    
    //float topMargin = self.navigationController.navigationBar.frame.size.height;
    //[self.collectionView setContentInset:UIEdgeInsetsMake(topMargin, 0, 0, 0)];
    
    // stop nav bar from resizing collection view cell when showing/hiding
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //NSLog(@"results array count: %d", [self.resultsArray count]);
    
    // Set title
    // DISABLED as we set the title in cellAtIndexPath method
    //self.title = titleFromList;
    
    // init comic store
    comicStore = [[KJComicStore alloc] init];
    
    // init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicDetailCell"];
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
    // Hide navbar
    self.navigationController.navigationBarHidden = YES;
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    // Gesture recognizer to show navbar when comic is double tapped
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comicWasDoubleTapped)];
    tapRecognizer.numberOfTapsRequired = 2;
    //tapRecognizer.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    // setup collection view and flow layout
    [self setupCollectionView];
    
    // scroll to same position in the collectionView
    // as we were on the previous view controller
    // TODO: write else statement for this
    // TODO: figure out why moving this screws the comic image bounds?
    // this might have something to do with incorrent image showing when a cell is tapped
    if (self.collectionViewIndexFromList != nil) {
        NSLog(@"scrolling to: %d", self.collectionViewIndexFromList.row);
        [self.collectionView scrollToItemAtIndexPath:self.collectionViewIndexFromList atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // reset isComingFromFavourites ivar
    isComingFromFavouritesList = NO;
}

@end
