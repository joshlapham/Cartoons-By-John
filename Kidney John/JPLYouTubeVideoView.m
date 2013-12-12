//
//  JPLYouTubeVideoView.m
//  Kidney John
//
//  Created by jl on 13/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeVideoView.h"
#import "MBProgressHUD.h"

@interface JPLYouTubeVideoView ()

@property (weak, nonatomic) IBOutlet UIWebView *videoView;

@end

@implementation JPLYouTubeVideoView

@synthesize videoIdFromList, videoTitleFromList;

static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>*{background-color:black;}body{margin:0px 0px 0px 0px;}</style><meta name = \"viewport\" content = \"initial-scale1.0, user-scalable=no\" /></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { playerVars: { autoplay: 1, showinfo: 0 }, width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

#pragma mark Play video method
- (void)playVideoWithId:(NSString *)videoId
{
    //NSLog(@"VIDEO ID: %@", videoId);
    
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, _videoView.frame.size.width, _videoView.frame.size.height, videoId];
    
    // NOTE - must include NSBundle resourceURL otherwise video autoplay will not work
    [_videoView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    // Hide progress
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark Video Favourites methods
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

#pragma mark Show UIActionSheet method
- (void)showActionSheet:(id)sender
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    NSString *other2 = @"Share";
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, other2, nil];
    
    // Add action sheet to view, taking in consideration the tab bar
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark UIActionSheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        [self addVideoToFavourites];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        [self removeVideoFromFavourites];
    } else if ([buttonPressed isEqualToString:@"Share"]) {
        NSLog(@"ACTION SHEET: whoa! hold your horses. that ain't implemented yet");
    }
}

#pragma mark init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show progress
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"";
    
    // Play video
    //NSLog(@"VIDEO DETAIL: videoId from list - %@", videoIdFromList);
    
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
