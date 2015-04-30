//
//  JPLYouTubeListView.m
//  Kidney John
//
//  Created by jl on 16/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeListView.h"
#import "MBProgressHUD.h"
#import "KJVideo.h"
#import "KJVideoStore.h"
#import "Reachability.h"
#import "JPLReachabilityManager.h"
#import "UIFont+KJFonts.h"
#import "NSUserDefaults+KJSettings.h"
#import "KJVideoViewController.h"
#import "KJVideoCell.h"
#import "UIColor+KJColours.h"
#import "UIViewController+KJUtils.h"

// Constants
// Segue identifiers
static NSString * kSegueIdentifierVideoDetail = @"videoIdSegue";

@interface JPLYouTubeListView () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

// Properties
@property (nonatomic, strong) NSArray *videoResults;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) UIAlertController *noNetworkAlertView;

@end

// TODO: refactor this class to use UISearchController

@implementation JPLYouTubeListView

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJVideoDataFetchDidHappenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

#pragma mark - Init method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = NSLocalizedString(@"Videos", @"Title of Videos view");
    
    // Set up NSNotification receiving for when videoStore finishes data fetch
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFetchDidFinish)
                                                 name:KJVideoDataFetchDidHappenNotification
                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Register cell with tableView
    [self.tableView registerNib:[UINib nibWithNibName:[KJVideoCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[KJVideoCell cellIdentifier]];
    
    // Register cell with search results tableView
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:[KJVideoCell cellIdentifier] bundle:nil]
                                              forCellReuseIdentifier:[KJVideoCell cellIdentifier]];
    
    // Fetch video data
    [self fetchDataWithNetworkCheck];
    
    // Set background if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Init image to use for background
        self.tableView.backgroundView = [self kj_noNetworkImageView];
        self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(fetchDataWithNetworkCheck)];
        _singleTap.numberOfTapsRequired = 1;
        [self.tableView addGestureRecognizer:_singleTap];
    }
    
    // Set placeholder and prompt text for UISearchBar
    NSString *searchPlaceholderString = NSLocalizedString(@"Search videos", @"Text displayed in search bar on videos list view");
    [self.searchDisplayController.searchBar setPlaceholder:searchPlaceholderString];
    
    // Set font of UISearchBar
    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].font = [UIFont kj_videoSearchBarFont];
    
    // Set searchbar to only show when tableView is scrolled
    self.tableView.contentOffset = CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height);
    
    // Set tableView row height
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.searchDisplayController.searchResultsTableView.estimatedRowHeight = 120;
    self.searchDisplayController.searchResultsTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Set background colour for view
    // Accessibility
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        self.view.backgroundColor = [UIColor kj_accessibilityDarkenColoursBackgroundColour];
    }
    
    else {
        self.view.backgroundColor = [UIColor kj_viewBackgroundColour];
    }
}

- (void)noNetworkConnection {
    // Init strings for noNetworkAlertView
    NSString *cancelButtonString = NSLocalizedString(@"Cancel", @"Title of Cancel button in No Network connection error alert");
    NSString *retryButtonString = NSLocalizedString(@"Retry", @"Title of Retry button in No Network connection error alert");
    
    // Init alert
    // NOTE - init using category method
    _noNetworkAlertView = [self kj_noNetworkAlertControllerWithNoActions];
    
    // Init actions
    // Retry
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:retryButtonString
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            // Retry data fetch
                                                            [self fetchDataWithNetworkCheck];
                                                        }];
    
    [_noNetworkAlertView addAction:retryAction];
    
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonString
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // Reload table data to check for empty data source
                                                             [self.tableView reloadData];
                                                         }];
    
    [_noNetworkAlertView addAction:cancelAction];
    
    // Check if first video data fetch has happened
    // NOTE - this will only show on very first app launch
    if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
        // Hide progress
        [_progressHud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Show alertView
        [self presentViewController:_noNetworkAlertView
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Videos: network became available");
        
        // Dismiss no network UIAlert
        [_noNetworkAlertView dismissViewControllerAnimated:YES
                                                completion:nil];
        
        // Fetch data
        [[KJVideoStore sharedStore] fetchVideoData];
    }
}

- (void)fetchDataWithNetworkCheck {
    // Show progress
    // Init MBProgressHUD
    _progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHud.userInteractionEnabled = NO;
    NSString *progressHudString = NSLocalizedString(@"Loading Videos ...", @"Message shown under progress wheel when videos are loading");
    _progressHud.labelText = progressHudString;
    _progressHud.labelFont = [UIFont kj_progressHudFont];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Check if first video data fetch has happened
    if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [[KJVideoStore sharedStore] fetchVideoData];
        }
        else if ([JPLReachabilityManager isUnreachable]) {
            [self noNetworkConnection];
        }
    }
    else {
        // We have data, so call this method to fetch from local DB and reload table
        [self videoFetchDidFinish];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [[KJVideoStore sharedStore] fetchVideoData];
        }
    }
}

#pragma mark - Data fetch did happen method

- (void)videoFetchDidFinish {
    DDLogVerbose(@"Videos: did receive notification that data fetch is complete");
    
    // Hide progress
    [_progressHud hide:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Set background of tableView to nil to remove any network error image showing
    if (![self.tableView.backgroundView isHidden]) {
        self.tableView.backgroundView = nil;
    }
    
    // Remove tap gesture recognizer
    [self.tableView removeGestureRecognizer:_singleTap];
}

#pragma mark - NSFetchedResultsController
#pragma mark -

// TODO: refactor to own data source class

#pragma mark Init controller methods

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString {
    // Init fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *videoEntity = [NSEntityDescription entityForName:@"KJVideo"
                                                   inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = videoEntity;
    
    // Init predicate if there is a search string
    NSPredicate *filterPredicate;
    
    if (searchString.length) {
        // Search by video name
        filterPredicate = [NSPredicate predicateWithFormat:@"videoName CONTAINS[cd] %@", searchString];
        fetchRequest.predicate = filterPredicate;
    }
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    fetchRequest.fetchBatchSize = 20;
    
    // Set sort descriptor (by video date, newest at top)
    NSSortDescriptor *videoDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"videoDate"
                                                                              ascending:NO];
    fetchRequest.sortDescriptors = @[ videoDateSortDescriptor ];
    
    // Init fetched results controller
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    
    // Set delegate
    fetchedResultsController.delegate = self;
    
    // Perform fetch
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        DDLogError(@"%s - unresolved error %@, %@", __func__, error, [error userInfo]);
        
        // Show fatal error alert
        [self showFatalErrorAlert];
    }
    
    return fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController {
    if (_searchFetchedResultsController != nil) {
        return _searchFetchedResultsController;
    }
    
    // Init with search text
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    
    return _searchFetchedResultsController;
}

// Helper method to return appropriate NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

#pragma mark Delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

// didChangeSection
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// didChangeObject
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:(KJVideoCell *)[tableView cellForRowAtIndexPath:indexPath]
                               atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}

#pragma mark - UISearchDisplayController
#pragma mark -

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}

#pragma mark -
#pragma mark Search Bar

-   (void)searchDisplayController:(UISearchDisplayController *)controller
 willUnloadSearchResultsTableView:(UITableView *)tableView; {
    // search is done so get rid of the search fetched results controller and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

-  (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - UITableView delegate methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    
    if (sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[KJVideoCell cellIdentifier]
                                                        forIndexPath:indexPath];
    
    // Configure cell
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView]
                     configureCell:cell
                       atIndexPath:indexPath];
    
    return cell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
                   configureCell:(KJVideoCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath {
    // Init cell data
    KJVideo *cellVideo = [fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure cell
    [cell configureCellWithData:cellVideo];
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell data
    KJVideo *cellData;
    NSFetchedResultsController *resultsController;
    
    // If search results ..
    if ([self.searchDisplayController isActive]) {
        resultsController = [self fetchedResultsControllerForTableView:self.searchDisplayController.searchResultsTableView];
        cellData = [resultsController objectAtIndexPath:indexPath];
    }
    else {
        resultsController = [self fetchedResultsControllerForTableView:self.tableView];
        cellData = [resultsController objectAtIndexPath:indexPath];
    }
    
    // Init destination VC
    KJVideoViewController *destViewController = [[KJVideoViewController alloc] initWithVideoId:cellData.videoId];
    destViewController.title = cellData.videoName;
    destViewController.chosenVideo = cellData;
    
    // Init back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Videos", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    // Push it
    [self.navigationController pushViewController:destViewController
                                         animated:YES];
}

@end
