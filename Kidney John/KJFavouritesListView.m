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

@interface KJFavouritesListView () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *favouritesResults;
@property (nonatomic) BOOL areThereAnyFavourites;

@end

@implementation KJFavouritesListView

@synthesize favouritesResults;

#pragma mark - Core Data methods
- (void)getVideoFavourites
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
 
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    favouritesResults = [KJVideo MR_findAllWithPredicate:predicate inContext:localContext];
    
    // Check count of faveResults array and set areThereAnyFavourites bool accordingly
    if ([[self favouritesResults] count] == 0) {
        NSLog(@"FAVOURITES: results array is zero, setting areThereAnyFavourites to NO");
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
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Favourites" message:@"You haven't set any Favourites." delegate:self cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
        [av show];
    }
}

#pragma mark - UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"FAVOURITES: did dismiss no favourites alert view, popping Favourites List view");
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
    return [favouritesResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    KJVideo *cellVideo = [favouritesResults objectAtIndex:indexPath.row];
    cell.textLabel.text = cellVideo.videoName;
    
    return cell;
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"favouritesVideoSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [favouritesResults objectAtIndex:indexPath.row];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Favourites List";
    
    [self getVideoFavourites];
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
