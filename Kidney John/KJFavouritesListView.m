//
//  KJFavouritesListView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJFavouritesListView.h"
#import "JPLYouTubeVideoView.h"
#import "KJVideo.h"
#import "KJComic.h"
#import "Models/KJRandomImage.h"
#import "KJComicDetailView.h"
#import "KJComicStore.h"
#import "KJRandomView.h"

@interface KJFavouritesListView () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation KJFavouritesListView {
    KJComicStore *comicStore;
}

@synthesize titleForView, cellResults;

#pragma mark - UIAlertView delegate methods

- (void)thereAreNoFavourites
{
    //NSLog(@"FAVOURITES: in thereAreNoFavourites method");
    NSString *messageString = [NSString stringWithFormat:@"You haven't set any %@ as favourites", titleForView];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Favourites"
                                                 message:messageString
                                                delegate:self
                                       cancelButtonTitle:Nil
                                       otherButtonTitles:@"OK", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    //NSLog(@"FAVOURITES: did dismiss no favourites alert view, popping Favourites List view");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"favouriteCell";
    
    // Configure the cell...
    // Custom font
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = kjCustomFont;
    
    if ([titleForView isEqualToString:@"Videos"]) {
        KJVideo *cellData = [cellResults objectAtIndex:indexPath.row];
        cell.textLabel.text = cellData.videoName;
    } else if ([titleForView isEqualToString:@"Comix"]) {
        KJComic *cellData = [cellResults objectAtIndex:indexPath.row];
        cell.textLabel.text = cellData.comicName;
    } else if ([titleForView isEqualToString:@"Doodles"]) {
        KJRandomImage *cellData = [cellResults objectAtIndex:indexPath.row];
        cell.textLabel.text = cellData.imageDescription;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
        // Video
        [self performSegueWithIdentifier:@"favouritesVideoSegue" sender:self];
    } else if ([[cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        // Comix
        [self performSegueWithIdentifier:@"comicDetailSegueFromFavourites" sender:self];
    } else if ([[cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJRandomImage class]]) {
        // Doodles
        [self performSegueWithIdentifier:@"doodleDetailSegueFromFavourites" sender:self];
    }
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"favouritesVideoSegue"]) {
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [cellResults objectAtIndex:indexPath.row];
        destViewController.videoIdFromList = cellVideo.videoId;
        destViewController.videoTitleFromList = cellVideo.videoName;
        
        // Hide tabbar on detail view
        //destViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"comicDetailSegueFromFavourites"]) {
        
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        KJComic *comicCell = [cellResults objectAtIndex:indexPath.row];
        
        destViewController.nameFromList = comicCell.comicName;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        // TODO: need to pass a results array here
        // or comics favourites will not work.
        // may have to pass a whole KJComic object?
        destViewController.isComingFromFavouritesList = YES;
        // pass a results array to dest VC containing only one object, our chosen one
        if ([KJComicStore returnComicWithComicName:comicCell.comicName] != nil) {
            destViewController.resultsArray = [NSArray arrayWithObject:[KJComicStore returnComicWithComicName:comicCell.comicName]];
        }
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
        
    } else if ([segue.identifier isEqualToString:@"doodleDetailSegueFromFavourites"]) {
        
        KJRandomView *destViewController = segue.destinationViewController;
        KJRandomImage *cellData = [cellResults objectAtIndex:indexPath.row];
        
        destViewController.selectedImageFromFavouritesList = cellData;
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    comicStore = [[KJComicStore alloc] init];
    
    self.title = titleForView;
    
    NSLog(@"cell results: %d", [cellResults count]);
    
    if ([cellResults count] == 0) {
        [self thereAreNoFavourites];
    }
}

@end
