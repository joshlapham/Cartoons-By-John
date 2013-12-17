//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"

@interface KJComicDetailView ()

@end

@implementation KJComicDetailView

@synthesize nameFromList, comicImage, comicScrollView;

#pragma mark - UIScrollView delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.comicImage;
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"Comix";
    
    NSLog(@"COMIC DETAIL: name from list - %@", nameFromList);
    
    // Setup scrollview
    self.comicScrollView.delegate = self;
    self.comicScrollView.minimumZoomScale = 1.0;
    self.comicScrollView.maximumZoomScale = 3.0;
    self.comicScrollView.contentSize = self.comicImage.image.size;
    self.comicImage.frame = CGRectMake(0, 0, self.comicImage.image.size.width, self.comicImage.image.size.height);
    
    // Set image to be displayed
    self.comicImage.image = [UIImage imageNamed:nameFromList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.comicImage = nil;
    self.comicScrollView = nil;
    
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.comicImage = nil;
}

@end
