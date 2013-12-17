//
//  JPLYouTubeListView.m
//  YOUR_APP_NAME_HERE
//
//  Created by jl on 16/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeListView.h"
#import "GTLYouTube.h"
#import "JPLYouTubeVideoView.h"
#import "MBProgressHUD.h"
#import "Models/KJVideo.h"
#import "Models/KJVideoFromParse.h"
#import "Parse.h"

@interface JPLYouTubeListView ()

@property (nonatomic, strong) __block NSArray *videoResults;

@end

@implementation JPLYouTubeListView

@synthesize videoResults;

#pragma mark - Core Data methods
- (BOOL)checkIfVideoIsInDatabaseWithVideoId:(NSString *)videoId context:(NSManagedObjectContext *)context
{
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:context]) {
        NSLog(@"Yes, video does exist in database");
        return TRUE;
    } else {
        NSLog(@"No, video does NOT exist in database");
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

#pragma mark - Fetch videos method
- (void)callFetchMethod
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading videos ...";
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
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
            // Hide progress
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            // CORE DATA
            videoResults = [[NSArray alloc] init];
            // Sort videos with newest at top
            videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
            
            // Reload table data
            [[self tableView] reloadData];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark - UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // CORE DATA
    return [videoResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"videoResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];
    
    // Cell text
    UIFont *cellTextFont = [UIFont fontWithName:@"Helvetica" size:20];
    cell.textLabel.font = cellTextFont;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.textLabel.lineBreakMode = YES;
    cell.textLabel.text = cellVideo.videoName;
    //[cell.textLabel sizeToFit];
    
    // Cell detail text
    UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:16];
    cell.detailTextLabel.font = cellDetailTextFont;
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

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"videoIdSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];

        destViewController.videoIdFromList = cellVideo.videoId;
        destViewController.videoTitleFromList = cellVideo.videoName;
        
        // Hide tabbar on detail view
        //destViewController.hidesBottomBarWhenPushed = YES;
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
    
    // CORE DATA
    // Sort videos with newest at top
    //videoResults = [[NSArray alloc] init];
    //videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Start fetching videos from playlist
    [self callFetchMethod];
}

@end
