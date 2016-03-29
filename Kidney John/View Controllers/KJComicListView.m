//
//  KJComicListView.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicListView.h"
#import "Kidney_John-Swift.h"
#import "KJComic.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "JPLReachabilityManager.h"
#import "UIFont+KJFonts.h"
#import "NSUserDefaults+KJSettings.h"
#import "UIColor+KJColours.h"
#import "UIViewController+KJUtils.h"

// Constants
// collectionView insets (for all edges)
static CGFloat kCollectionViewEdgeInset = 20;

// Segue identifiers
static NSString * kSegueIdentifierComicDetail = @"comicDetailSegue";

@interface KJComicListView () <NSFetchedResultsControllerDelegate>

// Properties
@property (nonatomic, strong) NSArray *comicResults;
@property (nonatomic, strong) UIAlertController *noNetworkAlert;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

// NSFetchedResultsController
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@end

@implementation KJComicListView

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotificationCenter observers
    // TODO: do we need this notification after CloudKit refactor?
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:KJComicDataFetchDidHappenNotification
    //                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init title
    self.title = NSLocalizedString(@"Comix", @"Title of Comics view");
    
    // Init collection view cell
    [self.collectionView registerClass:[KJComicCell class]
            forCellWithReuseIdentifier:[KJComicCell cellIdentifier]];
    
    // Setup collectionView
    [self setupCollectionView];
    
    // Register NSNotifications
    // TODO: do we need this notification after CloudKit refactor?
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(comicFetchDidHappen)
    //                                                 name:KJComicDataFetchDidHappenNotification
    //                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Perform fetch
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        DDLogError(@"%s - unresolved error %@, %@", __func__, error, [error userInfo]);
        
        // Show fatal error alert
        [self showFatalErrorAlert];
    }
    
    // Fetch comic data
    [self fetchDataWithNetworkCheck];
    
    // Set background image if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Init image to use for table background
        _backgroundImageView = [self kj_noNetworkImageView];
        
        // Add to background
        [self.collectionView addSubview:_backgroundImageView];
        self.collectionView.backgroundView = _backgroundImageView;
        self.collectionView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Init gesture recognizer to reload data if tapped
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(fetchDataWithNetworkCheck)];
        _singleTap.numberOfTapsRequired = 1;
        [self.collectionView addGestureRecognizer:_singleTap];
    }
}

#pragma mark - Setup collectionView helper method

- (void)setupCollectionView {
    // Set collectionView properties
    // Accessibility
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        self.collectionView.backgroundColor = [UIColor kj_accessibilityDarkenColoursBackgroundColour];
    }
    
    else {
        self.collectionView.backgroundColor = [UIColor kj_viewBackgroundColour];
    }
}

#pragma mark - NSFetchedResultsController

#pragma mark Init fetched results controller

// TODO: refactor this out to own data class

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init sort descriptor
    NSSortDescriptor *comicNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comicNumber"
                                                                          ascending:YES];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = @[ comicNumberDescriptor ];
    
    // Init fetched results controller
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark Delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                }
            }];
        }
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
    }];
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[KJComicCell cellIdentifier]
                                                                                 forIndexPath:indexPath];
    
    // Init cell data
    KJComic *cellData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure cell
    [cell configureCellWithData:cellData];
    
    return cell;
}

-   (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Init from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ImageStoryboard" bundle:nil];
    SingleImageViewController *destViewController = [storyboard instantiateViewControllerWithIdentifier:@"SingleImageViewController"];
    destViewController.hidesBottomBarWhenPushed = YES;
    
    // Init path to chosen cell
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    
    // Init cell data
    KJComic *cellData = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    
    // Set image
    destViewController.imageToShow = cellData;
    
    // Push it
    [self.navigationController pushViewController:destViewController
                                         animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kCollectionViewEdgeInset, kCollectionViewEdgeInset, kCollectionViewEdgeInset, kCollectionViewEdgeInset);
}

#pragma mark - Data fetch did happen method

- (void)comicFetchDidHappen {
    DDLogVerbose(@"%s - comic fetch did happen ..", __func__);
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [_progressHud hide:YES];
    
    // Set background of collectionView to nil to remove any network error image showing
    if (![_backgroundImageView isHidden]) {
        [_backgroundImageView removeFromSuperview];
        self.collectionView.backgroundView = nil;
    }
    
    // Remove tap gesture recognizer
    [self.collectionView removeGestureRecognizer:_singleTap];
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"%s: network became available", __func__);
        
        // Dismiss no network UIAlert
        [_noNetworkAlert dismissViewControllerAnimated:YES
                                            completion:nil];
        
        // Fetch data
        // TODO: revise this after refactor to CloudKit
        //        [[KJComicStore sharedStore] fetchComicData];
    }
}

- (void)noNetworkConnection {
    // Init strings for noNetworkAlertView
    NSString *cancelButtonString = NSLocalizedString(@"Cancel", @"Title of Cancel button in No Network connection error alert");
    NSString *retryButtonString = NSLocalizedString(@"Retry", @"Title of Retry button in No Network connection error alert");
    
    // Init UIAlertController
    _noNetworkAlert = [self kj_noNetworkAlertControllerWithNoActions];
    
    // Init actions
    // Retry
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:retryButtonString
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self fetchDataWithNetworkCheck];
                                                        }];
    
    [_noNetworkAlert addAction:retryAction];
    
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonString
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // Reload collectionView data to check for empty data source
                                                             [self.collectionView reloadData];
                                                         }];
    
    [_noNetworkAlert addAction:cancelAction];
    
    // Check if first comic data fetch has happened
    if (![NSUserDefaults kj_hasFirstComicFetchCompletedSetting]) {
        // Hide progress
        [_progressHud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Show alertView
        [self presentViewController:_noNetworkAlert
                           animated:YES
                         completion:nil];
    }
}

- (void)fetchDataWithNetworkCheck {
    // Show progress
    // Init MBProgressHUD
    _progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHud.userInteractionEnabled = NO;
    NSString *progressHudString = NSLocalizedString(@"Loading Comix ...", @"Message shown under progress wheel when comics are loading");
    _progressHud.labelText = progressHudString;
    _progressHud.labelFont = [UIFont kj_progressHudFont];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Check if first comic data fetch has happened
    if (![NSUserDefaults kj_hasFirstComicFetchCompletedSetting]) {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            // TODO: revise this after refactor to CloudKit
            //            [[KJComicStore sharedStore] fetchComicData];
        }
        
        else if ([JPLReachabilityManager isUnreachable]) {
            // Show noNetworkAlertView
            [self noNetworkConnection];
        }
    }
    
    // We have data, so call this method to fetch from local DB and reload table
    else {
        [self comicFetchDidHappen];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            // TODO: revise this after refactor to CloudKit
            //            [[KJComicStore sharedStore] fetchComicData];
        }
    }
}

@end
