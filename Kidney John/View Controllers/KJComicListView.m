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
#import "KJComic+Methods.h"
#import "MBProgressHUD.h"
#import "KJComicStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "JPLReachabilityManager.h"
#import "UIFont+KJFonts.h"
#import "NSUserDefaults+KJSettings.h"

// Constants
static NSString *kComicCellIdentifier = @"comicCell";

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *comicResults;
@property (nonatomic, strong) UIAlertView *noNetworkAlertView;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJComicDataFetchDidHappenNotification
                                                  object:nil];
    
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
            forCellWithReuseIdentifier:kComicCellIdentifier];
    
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
    
    // Core Data
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Fetch comic data
    [self fetchDataWithNetworkCheck];
    
    // Set background image if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Init image to use for table background
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        
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

#pragma mark - NSFetchedResultsController

#pragma mark Init fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KJComic"
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
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kComicCellIdentifier
                                                                                 forIndexPath:indexPath];
    
    // Init cell data
    KJComic *cellData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Set comic thumbnail using SDWebImage
    [cell.comicImageView sd_setImageWithURL:[NSURL fileURLWithPath:[cellData returnThumbnailFilepathForComic]]
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

-   (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"Comix: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"comicDetailSegue" sender:self];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        // Init destination view controller
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        // Init path to chosen cell
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        // Init cell data
        KJComic *comicCell = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        
        // Pass comic to destination VC
        destViewController.initialComicToShow = comicCell;
        
        // Pass selected index path to destination VC
        destViewController.collectionViewIndexFromList = selectedIndexPath;
        
        DDLogVerbose(@"Comix: selected comic row: %d", selectedIndexPath.row);
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Data fetch did happen method

- (void)comicFetchDidHappen {
    DDLogVerbose(@"Comic fetch did happen ..");
    
    // TODO: update to use vanilla Core Data
    
    //    _comicResults = [[NSArray alloc] init];
    //    _comicResults = [KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES];
    
    
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
    
    // Reload collectionview with data just fetched on main thread
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.collectionView reloadData];
    //    });
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Comix: network became available");
        
        // Dismiss no network UIAlertView
        [_noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
        [[KJComicStore sharedStore] fetchComicData];
    }
}

- (void)noNetworkConnection {
    // Init strings for noNetworkAlertView
    NSString *titleString = NSLocalizedString(@"No Network", @"Title of error alert displayed when no network connection is available");
    NSString *messageString = NSLocalizedString(@"This app requires a network connection", @"Error message displayed when no network connection is available");
    NSString *cancelButtonString = NSLocalizedString(@"Cancel", @"Title of Cancel button in No Network connection error alert");
    NSString *retryButtonString = NSLocalizedString(@"Retry", @"Title of Retry button in No Network connection error alert");
    
    // Init alertView
    _noNetworkAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                     message:messageString
                                                    delegate:self
                                           cancelButtonTitle:cancelButtonString
                                           otherButtonTitles:retryButtonString, nil];
    
    // Check if first comic data fetch has happened
    if (![NSUserDefaults kj_hasFirstComicFetchCompletedSetting]) {
        // Hide progress
        [_progressHud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Show alertView
        [_noNetworkAlertView show];
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
            [[KJComicStore sharedStore] fetchComicData];
        }
        else if ([JPLReachabilityManager isUnreachable]) {
            // Show noNetworkAlertView
            [self noNetworkConnection];
        }
    }
    else {
        // We have data, so call this method to fetch from local DB and reload table
        [self comicFetchDidHappen];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [[KJComicStore sharedStore] fetchComicData];
        }
    }
}

#pragma mark - UIAlertView delegate methods

-       (void)alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex {
    DDLogVerbose(@"Comix List: alert button clicked: %d", buttonIndex);
    
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    }
    else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
        
        // Reload collectionView data to check for empty data source
        // TODO: maybe don't reload here?
        [self.collectionView reloadData];
    }
}

@end
