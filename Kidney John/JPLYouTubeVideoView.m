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

@synthesize videoIdFromList, videoTitleFromList, videoDescriptionFromList, videoDurationFromList;

static NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style><meta name = \"viewport\" content = \"initial-scale1.0, user-scalable=no\" /></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { playerVars: { autoplay: 1, showinfo: 0 }, width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";

- (void)playVideoWithId:(NSString *)videoId
{
    //NSLog(@"VIDEO ID: %@", videoId);
    
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, _videoView.frame.size.width, _videoView.frame.size.height, videoId];
    
    // NOTE - must include NSBundle resourceURL otherwise video autoplay will not work
    [_videoView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    // Hide progress
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

//- (void)playVideoWithId:(NSString *)videoId
//{
//    NSString *YTAPIKey = @"AIzaSyDABsoA128lKxXQxrEY8M7QTzf7Vl3yQR0";
//    NSString *urlString = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@&key=%@", videoId, YTAPIKey];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [_videoView loadRequest:request];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Show progress
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading ...";
    
    // Play video
    //NSLog(@"VIDEO ID FROM LIST: %@", videoIdFromList);
    // Set to allow autoplay
    _videoView.mediaPlaybackRequiresUserAction = NO;
    // Call play video method
    [self playVideoWithId:videoIdFromList];
    
    // Set video title field
    self.videoTitleField.numberOfLines = 0;
    self.videoTitleField.adjustsFontSizeToFitWidth = YES;
    self.videoTitleField.text = videoTitleFromList;
    // Set video description field
    self.videoDescriptionField.numberOfLines = 0;
    self.videoDescriptionField.adjustsFontSizeToFitWidth = YES;
    self.videoDescriptionField.text = videoDescriptionFromList;
    
    // NOTE - videoDurationFromList variable is synthesized but not yet used in this detail view
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
