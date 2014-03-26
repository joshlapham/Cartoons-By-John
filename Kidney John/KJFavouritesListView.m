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
#import "KJComic.h"
#import "KJComicDetailView.h"
#import "KJComicStore.h"

@interface KJFavouritesListView () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *allFavouritesResults;
@end

@implementation KJFavouritesListView {
    NSArray *videoFavouritesResults;
    NSArray *comicFavouritesResults;
    BOOL areThereAnyFavourites;
    BOOL videoSectionHeaderToShow;
    BOOL comicsSectionHeaderToShow;
    BOOL bothSectionHeadersToShow;
    KJComicStore *comicStore;
}

@synthesize allFavouritesResults;

#pragma mark - Core Data methods

- (void)getFavourites
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
 
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    videoFavouritesResults = [KJVideo MR_findAllWithPredicate:predicate inContext:localContext];
    comicFavouritesResults = [KJComic MR_findAllWithPredicate:predicate inContext:localContext];
    
    // Add Video and Comics favourites results to one array
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:videoFavouritesResults, comicFavouritesResults, nil];
    [self setAllFavouritesResults:array];
    array = nil;
    
    // DEBUGGING
    NSLog(@"FAVOURITES: video results: %lu, comic results: %lu", (unsigned long)[videoFavouritesResults count], (unsigned long)[comicFavouritesResults count]);
    
    // Check count of faveResults array and set areThereAnyFavourites bool accordingly
    if ([videoFavouritesResults count] == 0 && [comicFavouritesResults count] == 0) {
        NSLog(@"FAVOURITES: no favourites results found, setting areThereAnyFavourites to NO");
        areThereAnyFavourites = NO;
        [self thereAreNoFavourites];
        
        // Reload table data
        [[self tableView] reloadData];
    } else {
        //NSLog(@"FAVOURITES: results array has objects, setting areThereAnyFavourites to YES");
        areThereAnyFavourites = YES;
        
        // Reload table data
        [[self tableView] reloadData];
    }
}

#pragma mark - No Favourites method

- (void)thereAreNoFavourites
{
    if (areThereAnyFavourites == NO) {
        //NSLog(@"FAVOURITES: in thereAreNoFavourites method");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Favourites"
                                                     message:@"You haven't set any favourites"
                                                    delegate:self
                                           cancelButtonTitle:Nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
        
        // Just for fun
        // Be sure to include AVFoundation framework in project and import in this file
        //NSString *say = @"There are no favorites.";
        //AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        //AVSpeechUtterance *utter = [AVSpeechUtterance speechUtteranceWithString:say];
        //[synth speakUtterance:utter];
    }
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"FAVOURITES: did dismiss no favourites alert view, popping Favourites List view");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView - section methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (areThereAnyFavourites) {
        NSInteger videoSection = [videoFavouritesResults count];
        NSInteger comicsSection = [comicFavouritesResults count];
        
        // Return the appropriate amount of sections depending on video or comic results
        // REVIEW: this if statement could be better
        if (videoSection > 0 && comicsSection > 0) {
            //NSLog(@"FAVOURITES: there are two sections to show");
            bothSectionHeadersToShow = YES;
            return 2;
        } else if (videoSection > 0 && comicsSection == 0) {
            //NSLog(@"FAVOURITES: video section to show");
            videoSectionHeaderToShow = YES;
            return 1;
        } else if (videoSection == 0 && comicsSection > 0) {
            //NSLog(@"FAVOURITES: comics section to show");
            comicsSectionHeaderToShow = YES;
            return 1;
        } else {
            //NSLog(@"FAVOURITES: no sections to show? setting to 1");
            // REVIEW: setting this BOOL
            bothSectionHeadersToShow = YES;
            return 1;
        }
        
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [self.videoFavouritesResults count];
    
    if (areThereAnyFavourites) {
        
        NSArray *sectionContents = [[self allFavouritesResults] objectAtIndex:section];
        NSInteger rows = [sectionContents count];
        
        return rows;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (areThereAnyFavourites) {
        //NSLog(@"FAVOURITES: in titleForHeaderSection method");
        //NSLog(@"FAVOURITES: header to return: %@", [[self allFavouritesResults] objectAtIndex:section]);
        
        NSString *sectionHeader = [[NSString alloc] init];
        
        if (bothSectionHeadersToShow) {
            if (section == 0) {
                sectionHeader = @"Videos";
            } else if (section == 1) {
                sectionHeader = @"Comics";
            }
            return sectionHeader;
        } else if (videoSectionHeaderToShow) {
            sectionHeader = @"Videos";
            return sectionHeader;
        } else if (comicsSectionHeaderToShow) {
            sectionHeader = @"Comics";
            return sectionHeader;
        } else {
            return nil;
        }

    } else {
        return nil;
    }
}

#pragma mark - UITableView - cell delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionContents = [[self allFavouritesResults] objectAtIndex:[indexPath section]];
    
    static NSString *videoCellIdentifier = @"videoCell";
    static NSString *comicCellIdentifier = @"comicCell";
    
    // Configure the cell...
    // Custom font
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    
    // Check sectionContents array and if there is no count, then create a videoCell
    // This if statement will fire if there are no Favourited items
    if (![sectionContents count]) {
        // Change this 'cause it's bad code
        UITableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
        if (!videoCell) {
            videoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
        }
        return videoCell;
    } else {
        if ([[sectionContents objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
            //NSLog(@"is video");
            UITableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
            if (!videoCell) {
                videoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
            }
            KJVideo *cellVideo = [sectionContents objectAtIndex:indexPath.row];
            videoCell.textLabel.text = cellVideo.videoName;
            // Custom font
            videoCell.textLabel.font = kjCustomFont;
            //videoCell.detailTextLabel.text = @"Video";
            return videoCell;
        } else if ([[sectionContents objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
            //NSLog(@"is comic");
            UITableViewCell *comicCell = [tableView dequeueReusableCellWithIdentifier:comicCellIdentifier forIndexPath:indexPath];
            if (!comicCell) {
                comicCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
            }
            KJComic *cellComic = [sectionContents objectAtIndex:indexPath.row];
            comicCell.textLabel.text = cellComic.comicName;
            // Custom font
            comicCell.textLabel.font = kjCustomFont;
            //comicCell.detailTextLabel.text = @"Comic";
            return comicCell;
        } else {
            // Change this 'cause it's bad code
            UITableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier forIndexPath:indexPath];
            if (!videoCell) {
                videoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentifier];
            }
            return videoCell;
        }
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
        KJVideo *cellVideo = [videoFavouritesResults objectAtIndex:indexPath.row];
        destViewController.videoIdFromList = cellVideo.videoId;
        destViewController.videoTitleFromList = cellVideo.videoName;
        
        // Hide tabbar on detail view
        //destViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"comicDetailSegueFromFavourites"]) {
        KJComicDetailView *destViewController = segue.destinationViewController;
        KJComic *comicCell = [comicFavouritesResults objectAtIndex:indexPath.row];
        destViewController.nameFromList = comicCell.comicName;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        // TODO: need to pass a results array here
        // or comics favourites will not work.
        // may have to pass a whole KJComic object?
        destViewController.isComingFromFavouritesList = YES;
        // pass a results array to dest VC containing only one object, our chosen one
        if ([comicStore returnComicWithComicName:comicCell.comicName] != nil) {
            destViewController.resultsArray = [NSArray arrayWithObject:[comicStore returnComicWithComicName:comicCell.comicName]];
        }
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    comicStore = [[KJComicStore alloc] init];
    
    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = @"Favourites List";
    
    //[self getFavourites];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self getFavourites];
}

@end
