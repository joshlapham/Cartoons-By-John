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

@interface JPLYouTubeListView () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation JPLYouTubeListView {
    __block NSArray *videoResults;
    NSArray *searchResults;
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

#pragma mark - Core Data did finish loading NSNotification

- (void)dataFetchDidFinish
{
    NSLog(@"VIDEO LIST: did receive notification that data fetch is complete, reloading table ..");
    // Sort videos with newest at top
    videoResults = [[NSArray alloc] init];
    videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[self tableView] reloadData];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
        
        // Extend line seperator between list items to edge of screen
        if ([cell respondsToSelector:@selector(separatorInset)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
    }
    
    // Init the cell
    KJVideo *cellVideo;
    
    // Check if this is the video list or the search results list
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellVideo = [searchResults objectAtIndex:indexPath.row];
    } else {
        cellVideo = [videoResults objectAtIndex:indexPath.row];
    }
    
    // Cell text
    //UIFont *cellTextFont = [UIFont fontWithName:@"Helvetica" size:20];
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:22];
    cell.textLabel.font = kjCustomFont;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.textLabel.lineBreakMode = YES;
    cell.textLabel.text = cellVideo.videoName;
    //[cell.textLabel sizeToFit];
    
    // Cell detail text
    //UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:16];
    UIFont *kjCustomFontDetailText = [UIFont fontWithName:@"JohnRoderickPaine" size:18];
    cell.detailTextLabel.font = kjCustomFontDetailText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = cellVideo.videoDescription;
    
    // Cell thumbnail
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIImage *thumbnailImage = [UIImage imageWithData:cellVideo.videoThumb];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.imageView.image = thumbnailImage;
            [cell setNeedsLayout];
        });
    });

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeightFloat;
    
    KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];

    if ([cellVideo.videoCellHeight isEqual:@"<null>"]) {
        cellHeightFloat = 160;
    } else {
        cellHeightFloat = [cellVideo.videoCellHeight floatValue];
    }
    
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
    //self.title = @"Videos";
    
    // Extend line seperator between list items to edge of screen
    if ([self.tableView respondsToSelector:@selector(separatorInset)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    // Set navbar title
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor blackColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = @"Videos";
    self.navigationItem.titleView = navLabel;
    
    // Set up NSNotification receiving
    NSString *notificationName = @"KJDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataFetchDidFinish) name:notificationName object:nil];
    
    // Check if app has been run before, if so then use local Core Data, if not then wait for NSNotification
    // from the app delegate to inform us that data has been loaded locally into Core Data
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"firstLoadDone"] isEqualToString:@"1"]) {
        // Sort videos with newest at top
        videoResults = [[NSArray alloc] init];
        videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    } else {
        // Show progress
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading videos ...";
    }
}

@end
