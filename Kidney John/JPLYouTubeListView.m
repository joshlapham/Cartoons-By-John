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

@interface JPLYouTubeListView ()

@end

@implementation JPLYouTubeListView

@synthesize videoIdResults, videoTitleResults, videoDurationResults, videoDescriptionResults, videoThumbnailUrlResults, videoThumbnails, cellHeights;

- (void)callFetchMethod
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading videos ...";
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(defaultQueue, ^{
        NSLog(@"IN GCD DEFAULT QUEUE THREAD ...");
        
        // Query locations array from delegate
        PFQuery *query = [KJVideo query];
        
        // Query for videos for current day
        //[query whereKey:[self chosenDayFromDelegate] equalTo:@"1"];
        
        // Query for locations near user's current location within the chosen radius
        //[query whereKey:@"location" nearGeoPoint:_currentUserLocationForParse withinKilometers:[[NSUserDefaults standardUserDefaults] doubleForKey:@"distanceSliderValue"]];
        
        // DEBUGGING
        JPLYouTubeVideoProtocol *videoProtocol = [[JPLYouTubeVideoProtocol alloc] init];
        videoProtocol.delegate = self;
        
        // Query all videos
        [query whereKey:@"videoName" notEqualTo:@"LOL"];
        
        // Init locations array
        videoIdResults = [[NSMutableArray alloc] init];
        videoTitleResults = [[NSMutableArray alloc] init];
        videoDescriptionResults = [[NSMutableArray alloc] init];
        //videoDurationResults = [[NSMutableArray alloc] init];
        //videoThumbnailUrlResults = [[NSMutableArray alloc] init];
        videoThumbnails = [[NSMutableArray alloc] init];
        cellHeights = [[NSMutableArray alloc] init];
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        NSString *videoNameString = [NSString stringWithFormat:@"%@", object[@"videoName"]];
                        [videoTitleResults addObject:videoNameString];
                        
                        NSString *videoDescriptionString = [NSString stringWithFormat:@"%@", object[@"videoDescription"]];
                        [videoDescriptionResults addObject:videoDescriptionString];
                        
                        NSString *videoIdString = [NSString stringWithFormat:@"%@", object[@"videoId"]];
                        [videoIdResults addObject:videoIdString];
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", object[@"videoId"]];
                        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
                        
                        //NSLog(@"%@", thumbnailUrl);
                        NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
                        UIImage *thumbImage = [UIImage imageWithData:thumbData];
                        [videoThumbnails addObject:thumbImage];
                        
                        // TESTING - cellHeight
                        [cellHeights addObject:object[@"cellHeight"]];
                        
                    } else {
                        NSLog(@"VIDEO LIST: video not active: %@", object[@"videoName"]);
                    }
                    // END OF TESTING
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            // Hide progress
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            // Reload table data
            [[self tableView] reloadData];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"IN GCD MAIN QUEUE THREAD ...");
            
            // Fetch videos from playlist
            //[self fetchVideosFromPlaylist];
        });
        
    });
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Parse test object
    //PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //[testObject setObject:@"bar" forKey:@"foo"];
    //[testObject save];
    //PFObject *playlist = [PFObject objectWithClassName:@"Playlist"];
    //playlist[@"playlistId"] = @"PLiOr-6o_rXa-obnh8OvFPc6HvlB2ACOwm";
    //playlist[@"playlistName"] = @"Hoop Dance Tutorials for Beginners & Beyond";
    //[playlist saveInBackground];
    
    //[query whereKey:@"playlistId" equalTo:[self.playlistId]];

    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Set title
    self.title = @"Videos";
    
    // Start fetching videos from playlist
    [self callFetchMethod];
    
    // TESTING
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [videoTitleResults count];
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
    cell.textLabel.text = [videoTitleResults objectAtIndex:indexPath.row];
    //[cell.textLabel sizeToFit];
    
    // Cell detail text
    UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:16];
    cell.detailTextLabel.font = cellDetailTextFont;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = [videoDescriptionResults objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [videoDurationResults objectAtIndex:indexPath.row];
    // Sample duration time for now ..
    //cell.detailTextLabel.text = @"3:00";
    //CGSize size = [cell.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0]];
    //cell.detailTextLabel.frame = CGRectMake(cell.detailTextLabel.frame.origin.x, cell.detailTextLabel.frame.origin.y, size.width, size.height);
    //[cell.detailTextLabel sizeToFit];
    
    // Cell thumbnail
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", [self.videoIdResults objectAtIndex:indexPath.row]];
        //NSLog(@"%@", [self.videoIdResults objectAtIndex:indexPath.row]);
        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
        //NSLog(@"%@", thumbnailUrl);
        //UIImage *thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]];

        UIImage *thumbnailImage = [videoThumbnails objectAtIndex:indexPath.row];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.imageView.image = thumbnailImage;
            [cell setNeedsLayout];
        });
    });
    
    return cell;
}

#pragma mark - Set cell height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeightFloat;

    if ([[cellHeights objectAtIndex:indexPath.row] isEqual:@"<null>"]) {
        cellHeightFloat = 160;
    } else {
        cellHeightFloat = [[cellHeights objectAtIndex:indexPath.row] floatValue];
    }
    
    return cellHeightFloat;
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"videoIdSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        destViewController.videoIdFromList = [self.videoIdResults objectAtIndex:indexPath.row];
        destViewController.videoTitleFromList = [self.videoTitleResults objectAtIndex:indexPath.row];
        destViewController.videoDescriptionFromList = [self.videoDescriptionResults objectAtIndex:indexPath.row];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
