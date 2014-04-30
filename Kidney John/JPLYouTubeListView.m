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

@interface JPLYouTubeListView () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation JPLYouTubeListView {
    __block NSArray *videoResults;
    NSArray *searchResults;
    SDWebImageManager *webImageManager;
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
    NSLog(@"VIDEOS: did receive notification that data fetch is complete, reloading table ..");
    
    // Sort videos with newest at top
    videoResults = [[NSArray alloc] init];
    videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[self tableView] reloadData];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
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
    
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
        //NSLog(@"found image in cache");
    } else {
        //NSLog(@"no image in cache");
    }
    
    [webImageManager downloadWithURL:[NSURL URLWithString:urlString]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                //NSLog(@"video thumb download: %d of %d downloaded", receivedSize, expectedSize);
                            }
                           completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                               if (cellImage && finished) {
                                   thumbnailImageView.image = cellImage;
                                   // call setNeedsLayout so thumbnails are shown immediately
                                   [cell setNeedsLayout];
                               } else {
                                   NSLog(@"video thumbnail download error");
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - Prepare for segue

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

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Set title
    self.title = @"Videos";
    
    // Extend line seperator between list items to edge of screen
//    if ([self.tableView respondsToSelector:@selector(separatorInset)]) {
//        self.tableView.separatorInset = UIEdgeInsetsZero;
//    }
    
    // init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Set up NSNotification receiving
    NSString *notificationName = @"KJVideoDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFetchDidFinish) name:notificationName object:nil];
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading videos ...";
    
    // Fetch data from store
    KJVideoStore *store = [[KJVideoStore alloc] init];
    [store fetchVideoData];
    
    // Set prompt text for UISearchBar
    // NOTE: disabled for now, as the prompt has since been setup in Storyboard
    //self.searchDisplayController.searchBar.prompt = @"Type a video name";
}

- (void)dealloc
{
    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJVideoDataFetchDidHappen" object:nil];
}

@end
