//
//  JPLYouTubeVideoView.m
//  Kidney John
//
//  Created by jl on 13/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeVideoView.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>

@interface JPLYouTubeVideoView ()

@property (weak, nonatomic) IBOutlet UIWebView *videoView;

@end

@implementation JPLYouTubeVideoView

@synthesize videoIdFromList, videoTitleFromList;

// NOTE - autoplay is set in playerVars
static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>*{background-color:black;}body{margin:0px 0px 0px 0px;}</style><meta name = \"viewport\" content = \"initial-scale1.0, user-scalable=no\" /></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { playerVars: { autoplay: 0, showinfo: 0 }, width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

#pragma mark - Social media methods
- (void)postToTwitter
{
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ - Animation by Kidney John - https://www.youtube.com/watch?v=%@", videoTitleFromList, videoIdFromList]];
    
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

- (void)postToFacebook
{
    SLComposeViewController *faceSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [faceSheet setInitialText:[NSString stringWithFormat:@"%@ - Animation by Kidney John - https://www.youtube.com/watch?v=%@", videoTitleFromList, videoIdFromList]];
    
    [self presentViewController:faceSheet animated:YES completion:nil];
}

#pragma mark - Play video method
- (void)playVideoWithId:(NSString *)videoId
{
    //NSLog(@"VIDEO ID: %@", videoId);
    
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, _videoView.frame.size.width, _videoView.frame.size.height, videoId];
    
    [_videoView loadHTMLString:html baseURL:nil];
    
    // NOTE - must include NSBundle resourceURL otherwise video autoplay will not work (autoplay disabled for now)
    //[_videoView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    // Hide progress
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Video Favourites methods
- (void)addVideoToFavourites
{
    NSMutableArray *favouritesArray = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]) {
        // Get a mutable array of the favouritesArray from NSUserDefaults
        favouritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]];
    }
    
    // Check if videoId has already been favourited, proceed if not
    if ([favouritesArray containsObject:videoIdFromList]) {
        NSLog(@"VIDEO DETAIL: error - video has already been favourited");
    } else {
        // Add videoId to array
        [favouritesArray addObject:videoIdFromList];
        
        // DEBUGGING
        NSLog(@"VIDEO DETAIL: added videoId to favourites - %@", [favouritesArray lastObject]);
        NSLog(@"VIDEO DETAIL: favouritesArray count - %lu", (unsigned long)[favouritesArray count]);
        
        // NSUserDefaults likes immutable arrays, so convert back to an NSArray
        NSArray *favouritesArrayToSave = [NSArray arrayWithArray:favouritesArray];
        
        // Save array to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:favouritesArrayToSave forKey:@"favouritesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// TESTING
//- (void)addVideoToFavourites
//{
//    // Define keys
//    NSString *videoName = @"videoName";
//    NSString *videoId = @"videoId";
//    
//    // Create array to hold dicts
//    NSMutableArray *arrayOfDicts = [NSMutableArray array];
//    NSMutableArray *retrivedFavouritesArray = [[NSMutableArray alloc] init];
//    
//    // Create dict for new video favourite
//    NSDictionary *newFavouriteVideoDict = [NSDictionary dictionaryWithObjectsAndKeys:videoTitleFromList, videoName, videoIdFromList, videoId, nil];
//    
//    if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"videoFavourites"]) {
//        // Get a mutable array of the favouritesArray from NSUserDefaults
//        retrivedFavouritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"videoFavourites"]];
//        
//        for (int i = 0; i < [retrivedFavouritesArray count]; i++) {
//            // Temp dict variable to hold each retrived dict
//            NSDictionary *tempDict = [retrivedFavouritesArray objectAtIndex:i];
//            
//            if ([tempDict isEqualToDictionary:newFavouriteVideoDict]) {
//                NSLog(@"VIDEO DETAIL: FAV IS ALREADY SAVED!!");
//            } else {
//                // Add retrieved dict to array of dicts to be saved back to NSUserDefaults
//                [arrayOfDicts addObject:tempDict];
//            }
//        }
//    }
//    
//    // Add new video favourite dict to array
//    [arrayOfDicts addObject:newFavouriteVideoDict];
//    
//    // Debugging
//    //NSLog(@"Array of dicts: %@", arrayOfDicts);
//    
//    // Save to NSUserDefaults
//    [[NSUserDefaults standardUserDefaults] setObject:arrayOfDicts forKey:@"videoFavourites"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    // Debugging
//    NSLog(@"USERDEFAULTS DEBUGGING: %@", [[NSUserDefaults standardUserDefaults] arrayForKey:@"videoFavourites"]);
//    //NSLog(@"VIDEO DETAIL: added videoId to favourites - %@", [favouritesArray lastObject]);
//    //NSLog(@"VIDEO DETAIL: favouritesArray count - %lu", (unsigned long)[favouritesArray count]);
//}
// END OF TESTING

- (void)removeVideoFromFavourites
{
    NSMutableArray *favouritesArray = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]) {
        // Get a mutable array of the favouritesArray from NSUserDefaults
        favouritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]];
    }
    
    // Check if videoId has already been favourited, remove if so
    if ([favouritesArray containsObject:videoIdFromList]) {
        [favouritesArray removeObject:videoIdFromList];
        
        // DEBUGGING
        NSLog(@"VIDEO DETAIL: removed videoId from favourites - %@", videoIdFromList);
        NSLog(@"VIDEO DETAIL: favouritesArray count - %lu", (unsigned long)[favouritesArray count]);
        
        // NSUserDefaults likes immutable arrays, so convert back to an NSArray
        NSArray *favouritesArrayToSave = [NSArray arrayWithArray:favouritesArray];
        
        // Save array to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:favouritesArrayToSave forKey:@"favouritesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"VIDEO DETAIL: error - cannot remove videoId from Favourites as it is not one");
    }
}

#pragma mark - Show UIActionSheet method
- (void)showActionSheet:(id)sender
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    NSString *other2 = @"Share on Facebook";
    NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    //NSString *actionSheetTitle = @"Action";
    //NSString *destructiveTitle = @"Destructive button";
    
    // Set Favourites button text accordingly
    if (![[[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"] containsObject:videoIdFromList]) {
        // Add to favourites since this videoId isn't already favourited
        favouritesString = @"Add to Favourites";
    } else {
        // Remove from favourites if videoId is favourited
        favouritesString = @"Remove from Favourites";
    }
    
    // Init action sheet with Favourites and Share buttons
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, other2, other3, nil];
    
    // Add action sheet to view, taking in consideration the tab bar
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        [self addVideoToFavourites];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        [self removeVideoFromFavourites];
    } else if ([buttonPressed isEqualToString:@"Share on Twitter"]) {
        NSLog(@"ACTION SHEET: share on twitter button pressed");
        [self postToTwitter];
    } else if ([buttonPressed isEqualToString:@"Share on Facebook"]) {
        NSLog(@"ACTION SHEET: share on facebook button pressed");
        [self postToFacebook];
    }
}

#pragma mark - init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show progress
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"";
    
    // Play video
    //NSLog(@"VIDEO DETAIL: videoId from list - %@", videoIdFromList);
    
    // Set title to video title
    self.title = videoTitleFromList;
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
    // Set to enable/disable autoplay
    _videoView.mediaPlaybackRequiresUserAction = NO;
    //_videoView.scalesPageToFit = YES;
    _videoView.scrollView.scrollEnabled = NO;
    
    // Call play video method
    [self playVideoWithId:videoIdFromList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    self.videoView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.videoView = nil;
}

@end
