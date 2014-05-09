//
//  JPLYouTubeVideoView.m
//  Kidney John
//
//  Created by jl on 13/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeVideoView.h"
#import "JPLYouTubeListView.h"
#import "MBProgressHUD.h"
#import "KJVideo.h"
#import "KJVideoFavouriteActivity.h"
#import "KJVideoStore.h"
#import "JPLReachabilityManager.h"
#import "DDLog.h"

// Set log level
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface JPLYouTubeVideoView () <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *videoView;

@end

@implementation JPLYouTubeVideoView {
    MBProgressHUD *hud;
}

@synthesize videoIdFromList, videoTitleFromList;

#pragma mark - UIAlertView delegate methods

- (void)showErrorIfNoNetworkConnection
{
    NSString *messageString = NSLocalizedString(@"A network connection is required to watch videos", @"Cannot play the video as there is no network connection");
    
    UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:@"No Network"
                                                             message:messageString
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
    
    [noNetworkAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If OK button was tapped ..
    if (buttonIndex == 0) {
        // Go back to video list view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLogVerbose(@"%s", __FUNCTION__);
    
    if ([JPLReachabilityManager isUnreachable]) {
        // Hide progress
        [hud hide:YES];
        
        // Hide network activity indicator
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Stop loading webView
        [_videoView stopLoading];
        
        // Show no network error alert
        [self showErrorIfNoNetworkConnection];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogVerbose(@"%s", __FUNCTION__);
    
    // Hide progress
    [hud hide:YES];
    
    // Hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogVerbose(@"%s", __FUNCTION__);
    
    // Hide progress
    [hud hide:YES];
    
    // Hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    DDLogVerbose(@"Video Detail: failed to load video: %@", [error localizedDescription]);
}

#pragma mark - HTML for YouTube webview

// NOTE - autoplay is set in playerVars
// TODO: look at width and height variables in this string for auto layout issues
static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>*{background-color:black;}body{margin:0px 0px 0px 0px;}</style><meta name = \"viewport\" content = \"initial-scale1.0, user-scalable=no\" /></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { playerVars: { autoplay: 0, showinfo: 0, rel: 0, modestbranding: 1, controls: 0 }, width:'1024', height:'704', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

#pragma mark - Play video method

- (void)playVideoWithId:(NSString *)videoId
{
    // Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //DDLogVerbose(@"VIDEO ID: %@", videoId);
    
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, videoId];
    
    //DDLogVerbose(@"video width: %f, video height: %f", _videoView.frame.size.width, _videoView.frame.size.height);
    
    [_videoView loadHTMLString:html baseURL:nil];
    
    // TODO: review these settings for auto layout issues
    //_videoView.contentMode = UIViewContentModeScaleAspectFill;
    _videoView.scalesPageToFit = YES;
    _videoView.autoresizesSubviews = YES;
    
    // NOTE - must include NSBundle resourceURL otherwise video autoplay will not work (autoplay disabled for now)
    //[_videoView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}

#pragma mark - UIActivityView methods

- (void)showActivityView
{
    NSString *titleString;
    
    if (![KJVideoStore checkIfVideoIdIsAFavourite:videoIdFromList]) {
        titleString = @"Add To Favourites";
    } else {
        titleString = @"Remove From Favourites";
    }
    
    KJVideoFavouriteActivity *favouriteActivity = [[KJVideoFavouriteActivity alloc] initWithActivityTitle:titleString andVideoId:videoIdFromList];
    
    NSURL *activityUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoIdFromList]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[activityUrl] applicationActivities:@[favouriteActivity]];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set title to video title
    self.title = videoTitleFromList;
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActivityView)];
    
    // Init webView
    _videoView.delegate = self;
    
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
    
    // Go back to video list if changing views
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.videoView = nil;
}

@end
