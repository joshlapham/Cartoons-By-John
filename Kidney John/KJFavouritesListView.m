//
//  KJFavouritesListView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJFavouritesListView.h"
#import "JPLYouTubeVideoView.h"
#import "Models/KJVideo.h"
#import "Models/KJComic.h"
#import "KJComicDetailView.h"

@interface KJFavouritesListView () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *videoFavouritesResults;
@property (nonatomic, strong) NSArray *comicFavouritesResults;
@property (nonatomic, strong) NSArray *allFavouritesResults;
@property (nonatomic) BOOL areThereAnyFavourites;

@end

@implementation KJFavouritesListView

@synthesize allFavouritesResults;

#pragma mark - Core Data methods
- (void)getFavourites
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
 
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    self.videoFavouritesResults = [KJVideo MR_findAllWithPredicate:predicate inContext:localContext];
    self.comicFavouritesResults = [KJComic MR_findAllWithPredicate:predicate inContext:localContext];
    
    // Add Video and Comics favourites results to one array
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.videoFavouritesResults, self.comicFavouritesResults, nil];
    [self setAllFavouritesResults:array];
    array = nil;
    
    // DEBUGGING
    NSLog(@"FAVOURITES: video results: %lu, comic results: %lu", (unsigned long)[[self videoFavouritesResults] count], (unsigned long)[[self comicFavouritesResults] count]);
    
    // Check count of faveResults array and set areThereAnyFavourites bool accordingly
    if ([[self videoFavouritesResults] count] == 0 && [[self comicFavouritesResults] count] == 0) {
        NSLog(@"FAVOURITES: no favourites results found, setting areThereAnyFavourites to NO");
        self.areThereAnyFavourites = NO;
        [self thereAreNoFavourites];
    } else {
        NSLog(@"FAVOURITES: results array has objects, setting areThereAnyFavourites to YES");
        self.areThereAnyFavourites = YES;
    }
}

#pragma mark - No Favourites method
- (void)thereAreNoFavourites
{
    if (self.areThereAnyFavourites == NO) {
        //NSLog(@"FAVOURITES: in thereAreNoFavourites method");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Favourites"
                                                     message:@"You haven't set any Favourites."
                                                    delegate:self
                                           cancelButtonTitle:Nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    }
}

#pragma mark - UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"FAVOURITES: did dismiss no favourites alert view, popping Favourites List view");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    
    NSInteger sections = [[self allFavouritesResults] count];
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [self.videoFavouritesResults count];
    
    NSArray *sectionContents = [[self allFavouritesResults] objectAtIndex:section];
    NSInteger rows = [sectionContents count];
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionContents = [[self allFavouritesResults] objectAtIndex:[indexPath section]];
    
    static NSString *videoCellIdentifier = @"videoCell";
    static NSString *comicCellIdentifier = @"comicCell";
    
    // Configure the cell...
    
    // TESTING
    if ([[sectionContents objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
        NSLog(@"is video");
        UITableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
        if (!videoCell) {
            videoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        KJVideo *cellVideo = [sectionContents objectAtIndex:indexPath.row];
        videoCell.textLabel.text = cellVideo.videoName;
        videoCell.detailTextLabel.text = @"Video";
        return videoCell;
    } else if ([[sectionContents objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        NSLog(@"is comic");
        UITableViewCell *comicCell = [tableView dequeueReusableCellWithIdentifier:comicCellIdentifier forIndexPath:indexPath];
        if (!comicCell) {
            comicCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        KJComic *cellComic = [sectionContents objectAtIndex:indexPath.row];
        comicCell.textLabel.text = cellComic.comicName;
        comicCell.detailTextLabel.text = @"Comic";
        return comicCell;
    } else {
        return nil;
    }
    //END OF TESTING
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"favouritesVideoSegue"]) {
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [self.videoFavouritesResults objectAtIndex:indexPath.row];
        destViewController.videoIdFromList = cellVideo.videoId;
        destViewController.videoTitleFromList = cellVideo.videoName;
        
        // Hide tabbar on detail view
        //destViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"comicDetailSegueFromFavourites"]) {
        KJComicDetailView *destViewController = segue.destinationViewController;
        KJComic *comicCell = [self.comicFavouritesResults objectAtIndex:indexPath.row];
        destViewController.nameFromList = comicCell.comicData;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Favourites List";
    
    [self getFavourites];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
