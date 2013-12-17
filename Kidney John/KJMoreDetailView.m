//
//  KJMoreDetailView.m
//  Kidney John
//
//  Created by jl on 6/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreDetailView.h"

@interface KJMoreDetailView ()

@end

@implementation KJMoreDetailView

@synthesize nameFromList;

#pragma mark - Load URL in web view method
- (void)loadSocialMediaLink:(NSURL *)linkToLoad
{
    NSLog(@"MORE DETAIL: requesting link - %@", linkToLoad);
    NSURLRequest *req = [NSURLRequest requestWithURL:linkToLoad];
    [self.socialLinkView loadRequest:req];
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = nameFromList;
    
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
    self.socialLinkView = nil;
    
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.socialLinkView = nil;
}

@end
