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

- (void)loadSocialMediaLink:(NSURL *)linkToLoad
{
    NSLog(@"Requesting link: %@", linkToLoad);
    NSURLRequest *req = [NSURLRequest requestWithURL:linkToLoad];
    [self.socialLinkView loadRequest:req];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = nameFromList;
    
    if ([nameFromList isEqualToString:@"Facebook"]) {
        NSLog(@"Facebook");
        NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Twitter"]) {
        NSLog(@"Twitter");
        NSURL *url = [NSURL URLWithString:@"https://twitter.com/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Tumblr"]) {
        NSLog(@"Tumblr");
        NSURL *url = [NSURL URLWithString:@"http://johnroderickpaine.tumblr.com"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"YouTube"]) {
        NSLog(@"YouTube");
        NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/user/kidneyjohn"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Vimeo"]) {
        NSLog(@"Vimeo");
        NSURL *url = [NSURL URLWithString:@"http://vimeo.com/johnroderickpaine"];
        [self loadSocialMediaLink:url];
    } else if ([nameFromList isEqualToString:@"Instagram"]) {
        NSLog(@"Instagram");
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
    // Dispose of any resources that can be recreated.
}

@end
