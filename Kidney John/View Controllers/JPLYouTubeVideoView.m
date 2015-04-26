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
#import "NSUserDefaults+KJSettings.h"

// Constants
// YouTube video URL for social sharing
static NSString *kYouTubeVideoUrlForSharing = @"https://www.youtube.com/watch?v=%@";

// HTML string for YouTube video
// NOTE - autoplay is set in playerVars
// TODO: look at width and height variables in this string for Auto Layout issues
static NSString *kYouTubeVideoHTML = @"<!DOCTYPE html><html><head><style>*{background-color:black;}body{margin:0px 0px 0px 0px;}</style><meta name = \"viewport\" content = \"initial-scale1.0, user-scalable=no\" /></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { playerVars: { autoplay: 0, showinfo: 0, rel: 0, modestbranding: 1, controls: 0 }, width:'1024', height:'704', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

@interface JPLYouTubeVideoView () <UIWebViewDelegate, UIAlertViewDelegate>

// Properties
@property (weak, nonatomic) IBOutlet UIWebView *videoView;
@property (nonatomic, strong) MBProgressHUD *progressHud;

@end

@implementation JPLYouTubeVideoView

#pragma mark - dealloc method

- (void)dealloc {
    [self.videoView setDelegate:nil];
    [self.videoView stopLoading];
}

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSAssert if chosenVideo is nil.
    // NOTE - this is for debugging purposes, will never happen in production.
    NSAssert(self.chosenVideo, @"Cannot init Video View without a chosenVideo!");
    
    // Set title to video title
    self.title = self.chosenVideo.videoName;
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActivityView)];
    
    // Init webView
    _videoView.delegate = self;
    _videoView.scrollView.scrollEnabled = NO;
    
    // Set to enable/disable autoplay
    _videoView.mediaPlaybackRequiresUserAction = NO;
    
    // Call play video method
    [self playVideoWithId:self.chosenVideo.videoId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self.videoView setDelegate:nil];
    [self.videoView stopLoading];
    self.videoView = nil;
    
    // Go back to video list if changing views
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UIAlertView delegate methods

// TODO: refactor to use UIAlertController

- (void)showErrorIfNoNetworkConnection {
    // Init strings for noNetworkAlert
    NSString *titleString = NSLocalizedString(@"No Connection", @"Title of error alert displayed when no network connection is available");
    NSString *messageString = NSLocalizedString(@"A network connection is required to watch videos", @"Error message displayed when no network connection is available");
    NSString *okButtonString = NSLocalizedString(@"OK", @"Title of OK button in no network connection error alert");
    
    // Init alertView
    UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:titleString
                                                             message:messageString
                                                            delegate:self
                                                   cancelButtonTitle:okButtonString
                                                   otherButtonTitles:nil, nil];
    
    // Show alertView
    [noNetworkAlert show];
}

-       (void)alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If OK button was tapped ..
    if (buttonIndex == 0) {
        // Go back to video list view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // If network is unreachable
    if ([JPLReachabilityManager isUnreachable]) {
        // Hide progress
        [_progressHud hide:YES];
        
        // Hide network activity indicator
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Stop loading webView
        [_videoView stopLoading];
        
        // Show no network error alert
        [self showErrorIfNoNetworkConnection];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Hide progress
    [_progressHud hide:YES];
    
    // Hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-       (void)webView:(UIWebView *)webView
 didFailLoadWithError:(NSError *)error {
    // Hide progress
    [_progressHud hide:YES];
    
    // Hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    DDLogError(@"Video Detail VC: failed to load video: %@", [error localizedDescription]);
}

#pragma mark - Play video method

- (void)playVideoWithId:(NSString *)videoId {
    // Show progress
    _progressHud = [MBProgressHUD showHUDAddedTo:self.view
                                        animated:YES];
    _progressHud.labelText = @"";
    
    // Show network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Init HTML for videoView
    NSString *html = [NSString stringWithFormat:kYouTubeVideoHTML, videoId];
    [_videoView loadHTMLString:html
                       baseURL:nil];
    
    // NOTE: review these settings for any Auto Layout issues
    _videoView.scalesPageToFit = YES;
    _videoView.autoresizesSubviews = YES;
    
    // NOTE - must include NSBundle resourceURL otherwise video autoplay will not work (autoplay disabled for now)
    //[_videoView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}

#pragma mark - UIActivityView methods

- (void)showActivityView {
    // Init UIActivity
    KJVideoFavouriteActivity *favouriteActivity = [[KJVideoFavouriteActivity alloc] initWithVideo:self.chosenVideo];
    
    // Init URL for UIActivity (for social sharing)
    NSURL *activityUrl = [NSURL URLWithString:[NSString stringWithFormat:kYouTubeVideoUrlForSharing, self.chosenVideo.videoId]];
    
    // Init view controller for UIActivity
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[ activityUrl ]
                                                                             applicationActivities:@[ favouriteActivity ]];
    
    // Show UIActivity
    [self.navigationController presentViewController:activityVC
                                            animated:YES
                                          completion:nil];
}

@end
