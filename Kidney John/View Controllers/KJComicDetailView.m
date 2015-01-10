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

// Constants
static NSString *kComicDetailCellIdentifier = @"comicDetailCell";

@interface KJComicDetailView () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicDetailView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.titleFromList;
    
    // Call method to setup collectionView and flow layout
    [self setupCollectionView];
    
    // Register custom UICollectionViewCell with collectionView
    [self.collectionView registerClass:[KJComicDetailCell class]
            forCellWithReuseIdentifier:kComicDetailCellIdentifier];
    
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
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Reload collectionView
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.resultsArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJComicDetailCell *cell = (KJComicDetailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kComicDetailCellIdentifier
                                                                                             forIndexPath:indexPath];
    
    // Init cell data
    KJComic *cellData = [self.resultsArray objectAtIndex:indexPath.row];
    
    // TODO: review comic image loading here
    cell.comicImageView.image = [KJComicStore returnComicImageFromComicObject:cellData];
    
//    DDLogVerbose(@"Comics List: image: %@, index path: %d", cell.comicImageView.image, indexPath.row);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *currentCellIndex = [[self.collectionView indexPathsForVisibleItems] firstObject];
    
    // Init comic object for comic currently on-screen
    KJComic *cellData = [self.resultsArray objectAtIndex:currentCellIndex.row];
    
    // Set title to comic after scroll has finished
    self.title = cellData.comicName;
    
    // Update titleFromList so that Favourites will function correctly,
    // as our Favourites methods use this ivar
    // TODO: update to use property (KJComic)comicOnScreen
    self.titleFromList = cellData.comicName;
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView {
    // Init flow layout with options
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:self.collectionView.bounds.size];
    
    // Set collectionView flow layout
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Set collectionView options
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setFrame:self.view.frame];
    
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
    KJComic *cellData = [self.resultsArray objectAtIndex:currentCellIndex.row];
    // TODO: do we really need this method?
    UIImage *comicImageToShare = [KJComicStore returnComicImageFromComicObject:cellData];
    
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
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    
    // Toggle status bar
    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - NSNotification methods

- (void)notifyThatComicWasDoubleTapped {
    // Post NSNotification that comic was double tapped
    [[NSNotificationCenter defaultCenter] postNotificationName:KJComicWasDoubleTappedNotification
                                                        object:nil];
}

@end
