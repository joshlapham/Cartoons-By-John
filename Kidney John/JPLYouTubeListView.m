//
//  JPLYouTubeListView.m
//  Kidney John
//
//  Created by jl on 16/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeListView.h"
#import "JPLYouTubeVideoView.h"
#import "MBProgressHUD.h"
#import "Models/KJVideo.h"
#import "KJVideoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "JPLReachabilityManager.h"

@interface JPLYouTubeListView () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@end

@implementation JPLYouTubeListView {
    NSArray *videoResults;
    NSArray *searchResults;
    SDWebImageManager *webImageManager;
    MBProgressHUD *hud;
    UIAlertView *noNetworkAlertView;
    UITapGestureRecognizer *singleTap;
}

#pragma mark - UISearchBar methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.videoName CONTAINS[cd] %@", searchText];
    
    searchResults = [videoResults filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - NSNotification methods

- (void)videoFetchDidFinish
{
    DDLogVerbose(@"Videos: did receive notification that data fetch is complete, reloading table ..");
    
    // Sort videos with newest at top
    videoResults = [[NSArray alloc] init];
    videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Set background of tableView to nil to remove any network error image showing
    self.tableView.backgroundView = nil;
    
    // Remove tap gesture recognizer
    [self.tableView removeGestureRecognizer:singleTap];
    
    // Reload tableView
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If there is data ..
    if ([videoResults count] > 0 || [searchResults count] > 0) {
        return 1;
    } else {
        // No data
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check if this is the video list or the search list
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [videoResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"videoResultCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Init the cell
    KJVideo *cellVideo;
    
    // Check if this is the video list or the search results list
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellVideo = [searchResults objectAtIndex:indexPath.row];
    } else {
        cellVideo = [videoResults objectAtIndex:indexPath.row];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:103];
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:102];
    
    // Cell text
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:22];
    titleLabel.font = kjCustomFont;
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = cellVideo.videoName;
    
    // Cell detail text
    UIFont *kjCustomFontDetailText = [UIFont fontWithName:@"JohnRoderickPaine" size:18];
    durationLabel.font = kjCustomFontDetailText;
    durationLabel.textColor = [UIColor grayColor];
    durationLabel.numberOfLines = 0;
    
    // Placeholder duration
    if (cellVideo.videoDuration == nil) {
        durationLabel.text = @"0:30";
    } else {
        durationLabel.text = cellVideo.videoDuration;
    }
    
    // SDWebImage
    NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", cellVideo.videoId];
    
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
        //DDLogVerbose(@"found image in cache");
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback if image not in cache
    }
    
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType) {
                                    if (cellImage && !error) {
                                        DDLogVerbose(@"Videos: fetched video thumbnail image");
                                    } else {
                                        DDLogError(@"Videos: error fetching video thumbnail image: %@", [error localizedDescription]);
                                    }
                                }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeightFloat;
    
    //KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];
    
    // If no cell height value is found, then use default of 160
    // DISABLED for now. Not needed as we aren't using a video description
//    if ([cellVideo.videoCellHeight isEqual:@"<null>"]) {
//        cellHeightFloat = 160;
//    } else {
//        cellHeightFloat = [cellVideo.videoCellHeight floatValue];
//    }
    
    cellHeightFloat = 120;
    
    return cellHeightFloat;
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"videoIdSegue"]) {
        // Set this in every view controller so that the back button displays back instead of the root view controller name
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *indexPath;
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            cellVideo = [searchResults objectAtIndex:indexPath.row];
            destViewController.videoIdFromList = cellVideo.videoId;
            destViewController.videoTitleFromList = cellVideo.videoName;
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            cellVideo = [videoResults objectAtIndex:indexPath.row];
            destViewController.videoIdFromList = cellVideo.videoId;
            destViewController.videoTitleFromList = cellVideo.videoName;
        }
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogVerbose(@"Button clicked: %d", buttonIndex);
    
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    } else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
        
        // Reload table data to check for empty data source
        // TODO: maybe don't reload here?
        [self.tableView reloadData];
    }
}

- (void)noNetworkConnection
{
    noNetworkAlertView = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                    message:@"This app requires a network connection"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Retry", nil];
    
    if (![KJVideoStore hasInitialDataFetchHappened]) {
        
        // Hide progress
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [noNetworkAlertView show];
    }
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange
{
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Videos: network became available");
        
        // Dismiss no network UIAlertView
        [noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
        [KJVideoStore fetchVideoData];
    }
}

- (void)fetchDataWithNetworkCheck
{
    // Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"Loading Videos ...";
    hud.labelFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([KJVideoStore hasInitialDataFetchHappened]) {
        // We have data, so call this method to fetch from local DB and reload table
        [self videoFetchDidFinish];
        
        // Fetch new data if network is available
        if ([JPLReachabilityManager isReachable]) {
            [KJVideoStore fetchVideoData];
        }
        
    } else {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [KJVideoStore fetchVideoData];
        } else if ([JPLReachabilityManager isUnreachable]) {
            // TODO: implement fallback if not reachable and is first data load
            [self noNetworkConnection];
        }
    }
}

#pragma mark - Check for empty UITableView data source

- (void)checkForEmptyDataSource
{
    // Check for empty data source
    DDLogVerbose(@"%s", __FUNCTION__);
    
    int sections = [self.tableView numberOfSections];
    BOOL hasRows = NO;
    
    for (int i = 0; i < sections; i++) {
        hasRows = ([self.tableView numberOfRowsInSection:i] > 0) ? YES: NO;
    }
    
    if (sections == 0 || hasRows == NO) {
        DDLogVerbose(@"Video list data source is empty!");
        
        // Image to use for table background
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        [self.tableView addSubview:imageView];
        self.tableView.backgroundView = imageView;
        self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchDataWithNetworkCheck)];
        singleTap.numberOfTapsRequired = 1;
        [self.tableView addGestureRecognizer:singleTap];
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set title
    self.title = @"Videos";
    
    // init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Set up NSNotification receiving for when videoStore finishes data fetch
    NSString *notificationName = @"KJVideoDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFetchDidFinish)
                                                 name:notificationName
                                               object:nil];
    
    // Reachability NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    // Fetch video data
    [self fetchDataWithNetworkCheck];
    
    // Check if data source for tableView is empty
    [self checkForEmptyDataSource];
    
    // Set prompt text for UISearchBar
    // NOTE: disabled for now, as the prompt has since been setup in Storyboard
    //self.searchDisplayController.searchBar.prompt = @"Type a video name";
    
    // Set font of UISearchBar
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"JohnRoderickPaine" size:16]];
    
    // Set searchbar to only show when tableView is scrolled
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];
}

- (void)dealloc
{
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJVideoDataFetchDidHappen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
