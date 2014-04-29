//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"
#import "MBProgressHUD.h"
#import "KJComicDetailCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
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
}

@synthesize nameFromList, titleFromList, fileNameFromList, hud, resultsArray, collectionViewIndexFromList, isComingFromFavouritesList;

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"count for coll. view - %d", [self.resultsArray count]);
    return [self.resultsArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicDetailCell *cell = (KJComicDetailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicDetailCell" forIndexPath:indexPath];
    
    KJComic *cellData = [self.resultsArray objectAtIndex:indexPath.row];
    
    NSLog(@"cell data: %@, results count: %d", cellData.comicFileUrl, [self.resultsArray count]);
    
    cell.comicImageView.image = [comicStore returnComicImageFromComicObject:cellData];
    
    NSLog(@"image: %@, index path: %d", cell.comicImageView.image, indexPath.row);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.bounds.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    
    KJComic *cellData = [self.resultsArray objectAtIndex:currentCellIndex.row];
    
    // set title to comic after scroll has finished
    self.title = cellData.comicName;
    
    // update titleFromList so that Favourites will function correctly,
    // as our Favourites methods use this ivar
    titleFromList = cellData.comicName;
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView
{
    // Init flow layout with options
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:self.collectionView.bounds.size];
    
    // Set collectionView flow layout
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    //[self.collectionView.collectionViewLayout invalidateLayout];
    
    // Set collectionView options
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setFrame:self.view.frame];
    
    NSLog(@"collection view index from list: %@", collectionViewIndexFromList);
    
    // Scroll to comic that was selected in previous view controller
    [self.collectionView scrollToItemAtIndexPath:collectionViewIndexFromList atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - UIActionSheet delegate methods

- (void)showActionSheet:(id)sender
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    //NSString *other2 = @"Share on Facebook";
    //NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    
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

#pragma mark - Gesture recognizer methods

- (void)comicWasTapped
{
    NSLog(@"Comic was tapped");
    
    // Toggle navbar
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    
    // Toggle status bar
    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"CDV: row: %d", collectionViewIndexFromList.row);
    
    // Set title
    self.title = titleFromList;
    
    // Call method to setup collectionView and flow layout
    [self setupCollectionView];
    
    // Init comic store
    comicStore = [[KJComicStore alloc] init];
    
    // Init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJComicDetailCell class] forCellWithReuseIdentifier:@"comicDetailCell"];
    
    // Init action button in top right hand corner of navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
    // Gesture recognizer to show navbar when comic is single tapped
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comicWasTapped)];
    singleTap.numberOfTapsRequired = 1;
    //tapRecognizer.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:singleTap];
    
    // Gesture recognizer to zoom comicScrollView on cell when double tapped
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyThatComicWasDoubleTapped)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.collectionView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // reset isComingFromFavourites ivar
    isComingFromFavouritesList = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Hide navbar
    self.navigationController.navigationBarHidden = YES;
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - NSNotification methods

- (void)notifyThatComicWasDoubleTapped
{
    // Post NSNotification that comic was double tapped
    NSString *notificationName = @"KJComicWasDoubleTapped";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

//#pragma mark - ScrollView methods

//- (void)centerScrollViewContents {
//    CGSize boundsSize = comicScrollView.bounds.size;
//    CGRect contentsFrame = [[self.collectionView viewWithTag:101] frame];
//
//    if (contentsFrame.size.width < boundsSize.width) {
//        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
//    } else {
//        contentsFrame.origin.x = 0.0f;
//    }
//
//    if (contentsFrame.size.height < boundsSize.height) {
//        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
//    } else {
//        contentsFrame.origin.y = 0.0f;
//    }
//
//    // TODO: check this
//    [[self.collectionView viewWithTag:101] setFrame:contentsFrame];
//}

@end
