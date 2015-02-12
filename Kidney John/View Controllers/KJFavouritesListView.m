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
#import "KJVideo+Methods.h"
#import "KJComic.h"
#import "KJComic+Methods.h"
#import "KJRandomImage.h"
#import "KJComicDetailView.h"
#import "KJComicStore.h"
#import "KJRandomView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJVideoCell.h"
#import "KJComicListCell.h"

@interface KJFavouritesListView () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation KJFavouritesListView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.titleForView;
    
    // Register cells with tableView
    [self.tableView registerNib:[UINib nibWithNibName:[KJComicListCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[KJComicListCell cellIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[KJVideoCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[KJVideoCell cellIdentifier]];
    
    // Set auto row height for cells
    self.tableView.estimatedRowHeight = 122;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
    UIAlertController *noFavouritesAlertView = [UIAlertController alertControllerWithTitle:titleString
                                                                                   message:messageString
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions for alertView
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okButtonString
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           // Go back to previous view controller
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }];
    [noFavouritesAlertView addAction:okayAction];
    
    // Show alertView
    [self presentViewController:noFavouritesAlertView
                       animated:YES
                     completion:nil];
}

#pragma mark - UIAlertView delegate methods

-       (void)alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex
                                    animated:YES];
    
    // Go back to previous view controller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.cellResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Video cell
    if ([[self.cellResults firstObject] isKindOfClass:[KJVideo class]]) {
        // Init KJVideoCell
        KJVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:[KJVideoCell cellIdentifier]
                                                                 forIndexPath:indexPath];
        
        // Init cell data
        KJVideo *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        // Video name
        videoCell.videoTitle.text = cellData.videoName;
        
        // Video description
        videoCell.videoDescription.text = cellData.videoDescription;
        
        // Placeholder duration
        if (cellData.videoDuration == nil) {
            videoCell.videoDuration.text = @"0:30";
        } else {
            videoCell.videoDuration.text = cellData.videoDuration;
        }
        
        // SDWebImage
        NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString, cellData.videoId];
        
        // Check if image is in cache
        if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
            //DDLogVerbose(@"found image in cache");
            videoCell.videoThumbnail.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
        } else {
            // TODO: fallback if not in cache
            //DDLogVerbose(@"no image in cache");
        }
        
        // Return cell
        return videoCell;
    }
    
    // Comic cell
    else if ([[self.cellResults firstObject] isKindOfClass:[KJComic class]]) {
        // Init KJComicListCell
        KJComicListCell *comicCell = [tableView dequeueReusableCellWithIdentifier:[KJComicListCell cellIdentifier]
                                                                     forIndexPath:indexPath];
        
        // Init cell data
        KJComic *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        // Set cell label text
        comicCell.comicTitle.text = cellData.comicName;
        comicCell.comicThumbnail.image = [cellData returnComicThumbImageFromComic];
        
        // Return cell
        return comicCell;
    }
    
    // NOTE - returning nil by default
    return nil;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Videos
    if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
        [self performSegueWithIdentifier:@"favouritesVideoSegue" sender:self];
    }
    
    // Comics
    else if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        [self performSegueWithIdentifier:@"comicDetailSegueFromFavourites" sender:self];
    }
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Init index path
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    // Videos
    if ([segue.identifier isEqualToString:@"favouritesVideoSegue"]) {
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [self.cellResults objectAtIndex:indexPath.row];
        destViewController.chosenVideo = cellVideo;
    }
    
    // Comics
    else if ([segue.identifier isEqualToString:@"comicDetailSegueFromFavourites"]) {
        // Init destination view controller
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        // Init cell data
        KJComic *comicCell = [self.cellResults objectAtIndex:indexPath.row];
        
        // Pass chosen comic to detail view
        destViewController.initialComicToShow = comicCell;
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
