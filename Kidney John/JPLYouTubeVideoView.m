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

#pragma mark Add video to Favourites method
- (IBAction)addVideoToFavourites:(id)sender
{
    NSMutableArray *favouritesArray = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]) {
        // Get a mutable array of the favouritesArray from NSUserDefaults
        favouritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"favouritesArray"]];
    }
    
    // Add videoId to array
    [favouritesArray addObject:videoIdFromList];
    
    // DEBUGGING
    NSLog(@"VIDEO VIEW: added videoId to favourites - %@", [favouritesArray lastObject]);
    NSLog(@"VIDEO VIEW: favouritesArray count - %lu", (unsigned long)[favouritesArray count]);
    
    // NSUserDefaults likes immutable arrays, so convert back to an NSArray
    NSArray *favouritesArrayToSave = [NSArray arrayWithArray:favouritesArray];
    
    // Save array to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:favouritesArrayToSave forKey:@"favouritesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show progress
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading ...";
    
    // Play video
    //NSLog(@"VIDEO ID FROM LIST: %@", videoIdFromList);
    
    // Add button to add video to Favourites
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addVideoToFavourites:)];
    
    // Set to enable/disable autoplay
    _videoView.mediaPlaybackRequiresUserAction = NO;
    //_videoView.scalesPageToFit = YES;
    _videoView.scrollView.scrollEnabled = NO;
    
    // Call play video method
    [self playVideoWithId:videoIdFromList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.videoView = nil;
    
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
