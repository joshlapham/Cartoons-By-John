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
#import "KJVideo.h"
#import "KJVideoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "JPLReachabilityManager.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "NSUserDefaults+KJSettings.h"

// Constants
static NSString *kCellIdentifier = @"videoResultCell";
static NSString *kYouTubeVideoThumbnailUrl = @"https://img.youtube.com/vi/%@/default.jpg";

@interface JPLYouTubeListView () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *videoResults;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIAlertView *noNetworkAlertView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation JPLYouTubeListView

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KJVideoDataFetchDidHappenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
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
    
    // Fetch video data
    [self fetchDataWithNetworkCheck];
    
    // Set background if no network is available
    if ([JPLReachabilityManager isUnreachable]) {
        // Init image to use for table background
        // TODO: change image to UILabel
        UIImage *image = [UIImage imageNamed:@"no-data.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        // Add to tableView
        [self.tableView addSubview:imageView];
        self.tableView.backgroundView = imageView;
        self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Gesture recognizer to reload data if tapped
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchDataWithNetworkCheck)];
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
}

#pragma mark - UISearchBar methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.videoName CONTAINS[cd] %@", searchText];
    _searchResults = [_videoResults filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Data fetch did happen method

- (void)videoFetchDidFinish {
    DDLogVerbose(@"Videos: did receive notification that data fetch is complete, reloading table ..");
    
    // Sort videos with newest at top (by videoDate)
    _videoResults = [[NSArray alloc] init];
    _videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Hide progress
    [_hud hide:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Set background of tableView to nil to remove any network error image showing
    if (![self.tableView.backgroundView isHidden]) {
        self.tableView.backgroundView = nil;
    }
    
    // Remove tap gesture recognizer
    [self.tableView removeGestureRecognizer:_singleTap];
    
    // Reload tableView
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // If there is data ..
    if ([_videoResults count] > 0 || [_searchResults count] > 0) {
        return 1;
    }
    else {
        // No data
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Check if this is the video list or the search list
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
    else {
        return [_videoResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Init cell data
    KJVideo *cellVideo;
    
    // Check if this is the video list or the search results list
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellVideo = [_searchResults objectAtIndex:indexPath.row];
    } else {
        cellVideo = [_videoResults objectAtIndex:indexPath.row];
    }
    
    // Init labels for cell
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:103];
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:102];
    
    // Init label text
    // Video name
    titleLabel.font = [UIFont kj_videoNameFont];
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = cellVideo.videoName;
    
    // Video duration
    durationLabel.font = [UIFont kj_videoDurationFont];
    durationLabel.textColor = [UIColor kj_videoDurationTextColour];
    durationLabel.numberOfLines = 0;
    
    // Check if new video, add 'New!' label if so
    if ([self isNewVideo:cellVideo]) {
        [cell addSubview:[self newVideoLabel]];
    }
    
    // Placeholder duration
    if (cellVideo.videoDuration == nil) {
        durationLabel.text = @"0:30";
    } else {
        durationLabel.text = cellVideo.videoDuration;
    }
    
    // Init video thumbnail
    NSString *urlString = [NSString stringWithFormat:kYouTubeVideoThumbnailUrl, cellVideo.videoId];
    
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
        //DDLogVerbose(@"found image in cache");
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback if image not in cache
    }
    
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                    if (cellImage && !error) {
                                        DDLogVerbose(@"Videos: fetched video thumbnail image from URL: %@", url);
                                    } else {
                                        DDLogError(@"Videos: error fetching video thumbnail image: %@", [error localizedDescription]);
                                    }
                                }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"videoIdSegue"]) {
        // Set this in every view controller so that the back button displays back instead of the root view controller name
        // TODO: review this, not really best practice
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *indexPath;
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo;
        
        // If search results ..
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            cellVideo = [_searchResults objectAtIndex:indexPath.row];
        }
        else {
            indexPath = [self.tableView indexPathForSelectedRow];
            cellVideo = [_videoResults objectAtIndex:indexPath.row];
        }
        
        // Set chosen video on destination VC
        destViewController.chosenVideo = cellVideo;
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DDLogVerbose(@"Button clicked: %ld", (long)buttonIndex);
    
    if (buttonIndex == 1) {
        // Retry was clicked
        [self fetchDataWithNetworkCheck];
    }
    else if (buttonIndex == 0) {
        // Cancel was clicked
        // TODO: implement a new view with a button to retry data refresh here?
        
        // Reload table data to check for empty data source
        // TODO: maybe don't reload here?
        [self.tableView reloadData];
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
    
    // Check if first video data fetch has happened
    if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
        // Hide progress
        [_hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Show alertView
        [_noNetworkAlertView show];
    }
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Videos: network became available");
        
        // Dismiss no network UIAlertView
        [_noNetworkAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        // Fetch data
        [KJVideoStore fetchVideoData];
    }
}

- (void)fetchDataWithNetworkCheck {
    // Show progress
    // Init MBProgressHUD
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.userInteractionEnabled = NO;
    NSString *progressHudString = NSLocalizedString(@"Loading Videos ...", @"Message shown under progress wheel when videos are loading");
    _hud.labelText = progressHudString;
    _hud.labelFont = [UIFont kj_progressHudFont];
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Check if first video data fetch has happened
    if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
        // Check if network is reachable
        if ([JPLReachabilityManager isReachable]) {
            [KJVideoStore fetchVideoData];
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
            [KJVideoStore fetchVideoData];
        }
    }
}

#pragma mark - Highlight new videos methods

#pragma mark Check if video is new or not method

- (BOOL)isNewVideo:(KJVideo *)video {
    // Check date of video compared to today's date.
    // If less than two weeks old then we'll class the video as 'new'.
    
    // Init date object from videoDate
    NSDate *videoDate = [[self dateFormatter] dateFromString:video.videoDate];
    
    // Init date object for today's date
    NSDate *todayDate = [NSDate date];
    
    // Get day components (number of days since video date)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:videoDate
                                                     toDate:todayDate
                                                    options:NO];
    
    // Check if video is less than 14 days old
    if (dateComponents.day < 15) {
        DDLogVerbose(@"Videos: video %@ is new!", video.videoName);
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark Init date formatter method

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    [_dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    return _dateFormatter;
}

#pragma mark Init 'new' label

- (UILabel *)newVideoLabel {
    // Init frame for label
    CGRect labelFrame = CGRectMake(10, 3, 30, 30);
    
    // Init label
    UILabel *newVideoLabel = [[UILabel alloc] initWithFrame:labelFrame];
    newVideoLabel.font = [UIFont kj_videoNewLabelFont];
    newVideoLabel.textColor = [UIColor whiteColor];
    newVideoLabel.backgroundColor = [UIColor kj_newVideoLabelColour];
    newVideoLabel.numberOfLines = 0;
    newVideoLabel.textAlignment = NSTextAlignmentCenter;
    
    // Make label round
    newVideoLabel.layer.masksToBounds = YES;
    newVideoLabel.layer.cornerRadius = newVideoLabel.frame.size.width / 2;
    
    // Init text
    NSString *labelText = NSLocalizedString(@"New!", @"Text for label that highlights if a video is new");
    newVideoLabel.text = labelText;
    
    return newVideoLabel;
}

@end
