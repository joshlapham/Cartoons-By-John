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

@synthesize videoIdResults, videoTitleResults, videoDescriptionResults, videoThumbnails, cellHeights, videoResults;

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
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Thumbnails methods
- (void)fetchThumbnailForVideoId:(NSString *)videoIdThumbnailToFetch
{
    NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", videoIdThumbnailToFetch];
    NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
    NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
    UIImage *thumbImage = [UIImage imageWithData:thumbData];
    
    [videoThumbnails addObject:thumbImage];
}

#pragma mark - Fetch videos method
- (void)callFetchMethod
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading videos ...";
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *query = [KJVideoFromParse query];
        
        // DEBUGGING
        //JPLYouTubeVideoProtocol *videoProtocol = [[JPLYouTubeVideoProtocol alloc] init];
        //videoProtocol.delegate = self;
        
        // Query all videos
        [query whereKey:@"videoName" notEqualTo:@"LOL"];
        
        // Cache policy
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Init locations array
        //videoIdResults = [[NSMutableArray alloc] init];
        //videoTitleResults = [[NSMutableArray alloc] init];
        //videoDescriptionResults = [[NSMutableArray alloc] init];
        videoThumbnails = [[NSMutableArray alloc] init];
        //cellHeights = [[NSMutableArray alloc] init];
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // CORE DATA
                        [self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                        
                        //NSString *videoNameString = [NSString stringWithFormat:@"%@", object[@"videoName"]];
                        //[videoTitleResults addObject:videoNameString];
                        
                        //NSString *videoDescriptionString = [NSString stringWithFormat:@"%@", object[@"videoDescription"]];
                        //[videoDescriptionResults addObject:videoDescriptionString];
                        
                        //NSString *videoIdString = [NSString stringWithFormat:@"%@", object[@"videoId"]];
                        //[videoIdResults addObject:videoIdString];
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", object[@"videoId"]];
                        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
                        
                        //NSLog(@"%@", thumbnailUrl);
                        NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
                        UIImage *thumbImage = [UIImage imageWithData:thumbData];
                        [videoThumbnails addObject:thumbImage];
                        
                        //[cellHeights addObject:object[@"cellHeight"]];
                        
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
            //videoResults = [KJVideo MR_findAll];
            // Sort videos with newest at top
            videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
            
            // Reload table data
            [[self tableView] reloadData];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"IN GCD MAIN QUEUE THREAD ...");
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
    
    // Cell text
    UIFont *cellTextFont = [UIFont fontWithName:@"Helvetica" size:20];
    cell.textLabel.font = cellTextFont;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.textLabel.lineBreakMode = YES;
    //cell.textLabel.text = [videoTitleResults objectAtIndex:indexPath.row];
    //[cell.textLabel sizeToFit];
    
    // CORE DATA
    KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];
    cell.textLabel.text = cellVideo.videoName;
    
    // Cell detail text
    UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:16];
    cell.detailTextLabel.font = cellDetailTextFont;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    //cell.detailTextLabel.text = [videoDescriptionResults objectAtIndex:indexPath.row];
    // CORE DATA
    cell.detailTextLabel.text = cellVideo.videoDescription;
    
    // Cell thumbnail
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
//        // CORE DATA
//        //NSString *thumbnailUrl = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", cellVideo.videoId];
//        UIImage *thumbnailImage = [videoThumbnails objectAtIndex:indexPath.row];
//        //UIImage *thumbnailImage = thumbnailUrl;
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            cell.imageView.image = thumbnailImage;
//            [cell setNeedsLayout];
//        });
//    });
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeightFloat;
    
    // CORE DATA
    KJVideo *cellVideo = [videoResults objectAtIndex:indexPath.row];

//    if ([[cellHeights objectAtIndex:indexPath.row] isEqual:@"<null>"]) {
//        cellHeightFloat = 160;
//    } else {
//        cellHeightFloat = [[cellHeights objectAtIndex:indexPath.row] floatValue];
//    }

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
        //destViewController.videoIdFromList = [self.videoIdResults objectAtIndex:indexPath.row];
        //destViewController.videoTitleFromList = [self.videoTitleResults objectAtIndex:indexPath.row];
        
        // CORE DATA
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
    //videoResults = [[NSArray alloc] init];
    //videoResults = [KJVideo MR_findAll];
    // Sort videos with newest at top
    //videoResults = [KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO];
    
    // Start fetching videos from playlist
    [self callFetchMethod];
}

@end
