//
//  KJMoreDetailView.m
//  Kidney John
//
//  Created by jl on 6/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreDetailView.h"

@interface KJMoreDetailView () <UIWebViewDelegate>

@end

@implementation KJMoreDetailView {
    NSURLRequest *req;
}

@synthesize nameFromList, socialLinkView;

#pragma mark - Load URL in web view method
- (void)loadSocialMediaLink:(NSURL *)linkToLoad
{
    NSLog(@"MORE DETAIL: requesting link - %@", linkToLoad);
    req = [NSURLRequest requestWithURL:linkToLoad];
    [self.socialLinkView loadRequest:req];
}

#pragma mark - UIWebView delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"MORE DETAIL: in webViewDidStart method");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.title = nameFromList;
    
    // TESTING - navbar title
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor blackColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = nameFromList;
    self.navigationItem.titleView = navLabel;
    // END OF TESTING
    
    // TESTING - webview delegate
    socialLinkView.delegate = self;
    // END OF TESTING
    
    if ([nameFromList isEqualToString:@"Facebook"]) {
        NSLog(@"MORE DETAIL: Facebook");
        NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Twitter"]) {
        NSLog(@"MORE DETAIL: Twitter");
        NSURL *url = [NSURL URLWithString:@"https://twitter.com/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Tumblr"]) {
        NSLog(@"MORE DETAIL: Tumblr");
        NSURL *url = [NSURL URLWithString:@"http://johnroderickpaine.tumblr.com"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"YouTube"]) {
        NSLog(@"MORE DETAIL: YouTube");
        NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/user/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Vimeo"]) {
        NSLog(@"MORE DETAIL: Vimeo");
        NSURL *url = [NSURL URLWithString:@"http://vimeo.com/johnroderickpaine"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Instagram"]) {
        NSLog(@"MORE DETAIL: Instagram");
        NSURL *url = [NSURL URLWithString:@"http://instagram.com/johnroderickpaine"];
        [self loadSocialMediaLink:url];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    self.socialLinkView = nil;
    
    // Cancel URL request and stop network activity monitor
    req = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.socialLinkView = nil;
}

@end
