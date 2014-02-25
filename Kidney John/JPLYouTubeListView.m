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
#import "Parse.h"
#import "Models/KJVideoFromParse.h"

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
    
    // If no cell height value is found, then use default of 160
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
    
    // Navbar title label init
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    // Set title text colour
    navLabel.textColor = [UIColor whiteColor];
    // Set title
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
        // DISABLED - moved to app delegate data fetch method
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading videos ...";
        
        [self callVideoFetchMethod];
    }
    
    // Set prompt text for UISearchBar
    // NOTE: disabled for now, as the prompt has since been setup in Storyboard
    //self.searchDisplayController.searchBar.prompt = @"Type a video name";
}

#pragma mark - Fetch videos for Core Data methods

- (BOOL)checkIfVideoIsInDatabaseWithVideoId:(NSString *)videoId context:(NSManagedObjectContext *)context
{
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:context]) {
        //NSLog(@"Yes, video does exist in database");
        return TRUE;
    } else {
        //NSLog(@"No, video does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewVideoWithId:(NSString *)videoId
                         name:(NSString *)videoName
                  description:(NSString *)videoDescription
                         date:(NSString *)videoDate
                   cellHeight:(NSString *)videoCellHeight
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If video does not exist in database then persist
    if (![self checkIfVideoIsInDatabaseWithVideoId:videoId context:localContext]) {
        // Create a new video in the current context
        KJVideo *newVideo = [KJVideo MR_createInContext:localContext];
        
        // Set attributes
        newVideo.videoId = videoId;
        newVideo.videoName = videoName;
        newVideo.videoDescription = videoDescription;
        newVideo.videoDate = videoDate;
        newVideo.videoCellHeight = videoCellHeight;
        // Thumbnails
        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", videoId];
        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
        NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
        newVideo.videoThumb = thumbData;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)callVideoFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"VIDEO PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *query = [KJVideoFromParse query];
        
        // Query all videos
        [query whereKey:@"videoName" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        [self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                    } else {
                        NSLog(@"VIDEO LIST: video not active: %@", object[@"videoName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLoadDone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *notificationName = @"KJDataFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"VIDEO PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

@end
