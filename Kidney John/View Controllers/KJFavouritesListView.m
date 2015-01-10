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
#import "KJRandomImage.h"
#import "KJComicDetailView.h"
#import "KJComicStore.h"
#import "KJRandomView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJVideo+Methods.h"

static NSString *VideoCellIdentifier = @"favouriteCell";
static NSString *ComicCellIdentifier = @"comicFavouriteCell";

@interface KJFavouritesListView () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation KJFavouritesListView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.titleForView;
    
    // Check for Favourites results
    if ([self.cellResults count] == 0) {
        [self thereAreNoFavourites];
    }
}

#pragma mark - Show noFavouritesAlertView method

- (void)thereAreNoFavourites {
    // Init strings for noFavouritesAlertView
    NSString *titleString = NSLocalizedString(@"No Favourites", @"Title of error alert displayed when user hasn't favourited any items");
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"You haven't set any %@ as favourites", @"Message displayed when user hasn't favourited any {items}"), self.titleForView];
    NSString *okButtonString = NSLocalizedString(@"OK", @"Title of OK button in No Favourites error alert");
    
    // Init alertView
    UIAlertView *noFavouritesAlertView = [[UIAlertView alloc] initWithTitle:titleString
                                                 message:messageString
                                                delegate:self
                                       cancelButtonTitle:Nil
                                       otherButtonTitles:okButtonString, nil];
    
    // Show alertView
    [noFavouritesAlertView show];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    // Go back to previous view controller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellResults count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.cellResults firstObject] isKindOfClass:[KJComic class]]) {
        return 100;
    } else {
        return 120;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    UITableViewCell *cell;
    
    if (!cell) {
        if ([[self.cellResults firstObject] isKindOfClass:[KJComic class]]) {
            // Comics
            [tableView registerNib:[UINib nibWithNibName:@"KJComicFavouriteCell" bundle:nil]
            forCellReuseIdentifier:ComicCellIdentifier];
            
            cell = [tableView dequeueReusableCellWithIdentifier:ComicCellIdentifier
                                                   forIndexPath:indexPath];
        }
        else {
            // Videos
            cell = [tableView dequeueReusableCellWithIdentifier:VideoCellIdentifier
                                                   forIndexPath:indexPath];
        }
    }
    
    // Init cell labels
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UIImageView *thumbImage = (UIImageView *)[cell viewWithTag:102];
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:103];
    
    // Video name
    titleLabel.font = [UIFont kj_videoNameFont];
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // If Video ..
    if ([[self.cellResults firstObject] isKindOfClass:[KJVideo class]]) {
        
        // Init cell data
        KJVideo *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        // Video name
        titleLabel.text = cellData.videoName;
        
        // Video duration
        UIFont *kjCustomFontDetailText = [UIFont kj_videoDurationFont];
        durationLabel.font = kjCustomFontDetailText;
        durationLabel.textColor = [UIColor kj_videoDurationTextColour];
        durationLabel.numberOfLines = 0;
        
        // Placeholder duration
        // TODO: review this
        if (cellData.videoDuration == nil) {
            durationLabel.text = @"0:30";
        } else {
            durationLabel.text = cellData.videoDuration;
        }
        
        // SDWebImage
        NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString, cellData.videoId];
        
        // Check if image is in cache
        if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
            //DDLogVerbose(@"found image in cache");
            thumbImage.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
        } else {
            // TODO: fallback if not in cache
            //DDLogVerbose(@"no image in cache");
        }
        
    }
    else if ([[self.cellResults firstObject] isKindOfClass:[KJComic class]]) {
        KJComic *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        titleLabel.text = cellData.comicName;
        
        thumbImage.image = [KJComicStore returnComicThumbImageFromComicObject:cellData];
        thumbImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    else if ([self.titleForView isEqualToString:@"Doodles"]) {
        // TODO: do we need this else-if statement for Doodles?
        KJRandomImage *cellData = [self.cellResults objectAtIndex:indexPath.row];
        titleLabel.text = cellData.imageDescription;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
        // Video
        [self performSegueWithIdentifier:@"favouritesVideoSegue" sender:self];
    }
    else if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        // Comix
        [self performSegueWithIdentifier:@"comicDetailSegueFromFavourites" sender:self];
    }
    else if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJRandomImage class]]) {
        // Doodles
        [self performSegueWithIdentifier:@"doodleDetailSegueFromFavourites" sender:self];
    }
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    // TODO: review this, not really best practice
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:@"favouritesVideoSegue"]) {
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [self.cellResults objectAtIndex:indexPath.row];
        destViewController.chosenVideo = cellVideo;
    }
    else if ([segue.identifier isEqualToString:@"comicDetailSegueFromFavourites"]) {
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        KJComic *comicCell = [self.cellResults objectAtIndex:indexPath.row];
        
        destViewController.nameFromList = comicCell.comicName;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        
        // Pass a results array to dest VC containing only one object, our chosen one
        if ([KJComicStore returnComicWithComicName:comicCell.comicName] != nil) {
            destViewController.resultsArray = [NSArray arrayWithObject:[KJComicStore returnComicWithComicName:comicCell.comicName]];
        }
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"doodleDetailSegueFromFavourites"]) {
        KJRandomView *destViewController = segue.destinationViewController;
        KJRandomImage *cellData = [self.cellResults objectAtIndex:indexPath.row];
        destViewController.selectedImageFromFavouritesList = cellData;
    }
}

@end
