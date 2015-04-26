//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"
#import "KJComicDetailCell.h"
#import "KJComicStore.h"
#import "KJComicFavouriteActivity.h"
#import "KJComic.h"
#import "KJComic+Methods.h"
#import "NSUserDefaults+KJSettings.h"
#import "KJParseAnalyticsStore.h"

@interface KJComicDetailView () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

// Properties
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellDataSource;

@end

@implementation KJComicDetailView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.initialComicToShow.comicName;
    
    // Init cell data source array
    // NOTE - we check if we're coming from KJComicList VC or KJFavList VC here, so we can best init data source array.
    // ALSO NOTE - this is hacky, and a major refactor of this view controller is on its' way soon anyway.
    // If collectionViewIndexFromList property is nil, that means we're coming from KJFavList
    if (!self.collectionViewIndexFromList) {
        // Init array with just initialComicToShow object, as that's all we need
        _cellDataSource = @[ self.initialComicToShow ];
        
        // Track comic viewed with Parse Analytics (if enabled)
        if ([NSUserDefaults kj_shouldTrackViewedComicEventsWithParseSetting]) {
            [[KJParseAnalyticsStore sharedStore] trackComicViewEventForComic:self.initialComicToShow];
        }
    }
    
    // Coming from KJComicList VC
    else {
        // Init array of all comics in Core Data
        _cellDataSource = [[KJComicStore sharedStore] returnComicsArray];
        
        // Track comic viewed with Parse Analytics (if enabled)
        if ([NSUserDefaults kj_shouldTrackViewedComicEventsWithParseSetting]) {
            KJComic *chosenComic = [_cellDataSource objectAtIndex:self.collectionViewIndexFromList.row];
            [[KJParseAnalyticsStore sharedStore] trackComicViewEventForComic:chosenComic];
        }
    }
    
    // Call method to setup collectionView and flow layout
    [self setupCollectionView];
    
    // Register custom UICollectionViewCell with collectionView
    [self.collectionView registerClass:[KJComicDetailCell class]
            forCellWithReuseIdentifier:[KJComicDetailCell cellIdentifier]];
    
    // Init action button in top right hand corner of navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActivityView)];
    
    // Gesture recognizer to show navbar when comic is single tapped
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(comicWasTapped)];
    
    singleTap.numberOfTapsRequired = 1;
    [self.collectionView addGestureRecognizer:singleTap];
    
    // Gesture recognizer to zoom comicScrollView on cell when double tapped
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(notifyThatComicWasDoubleTapped)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [self.collectionView addGestureRecognizer:doubleTap];
    
    // Differentiate between single tap and double tap
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navbar
    self.navigationController.navigationBarHidden = YES;
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [_cellDataSource count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJComicDetailCell *cell = (KJComicDetailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[KJComicDetailCell cellIdentifier]
                                                                                             forIndexPath:indexPath];
    
    // Init cell data
    KJComic *cellData = [_cellDataSource objectAtIndex:indexPath.row];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    
    // Init comic object for comic currently on-screen
    KJComic *cellData = [_cellDataSource objectAtIndex:currentCellIndex.row];
    
    // Set title to comic after scroll has finished
    self.title = cellData.comicName;
    
    // Update initialComic so that Favourites will function correctly, as our Favourites methods use this property
    self.initialComicToShow = cellData;
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView {
    // Init flow layout with options
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.itemSize = self.collectionView.bounds.size;
    
    // Set collectionView flow layout
    self.collectionView.collectionViewLayout = flowLayout;
    
    // Set collectionView options
    self.collectionView.pagingEnabled = YES;
    self.collectionView.frame = self.view.frame;
    
    // Scroll to comic that was selected in previous view controller
    [self.collectionView scrollToItemAtIndexPath:self.collectionViewIndexFromList
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - UIActivityView methods

- (void)showActivityView {
    // Get data for comic currently on screen
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    KJComic *cellData = [_cellDataSource objectAtIndex:currentCellIndex.row];
    
    // Init comic image
    // TODO: do we really need this method?
    UIImage *comicImageToShare = [cellData returnComicImageFromComic];
    
    // Init UIActivity
    KJComicFavouriteActivity *favouriteActivity = [[KJComicFavouriteActivity alloc] initWithComic:cellData];
    
    // Init view controller for UIActivity
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[comicImageToShare]
                                                                             applicationActivities:@[favouriteActivity]];
    
    // Set excluded activity types for UIActivity view controller
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
    
    // Present UIActivityController
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Gesture recognizer methods

- (void)comicWasTapped {
    DDLogVerbose(@"Comic Detail: comic was tapped");
    
    // Toggle navbar
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden
                                             animated:YES];
    
    // Toggle status bar
    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden]
                                            withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - NSNotification methods

- (void)notifyThatComicWasDoubleTapped {
    // Post NSNotification that comic was double tapped
    [[NSNotificationCenter defaultCenter] postNotificationName:KJComicWasDoubleTappedNotification
                                                        object:nil];
}

@end
