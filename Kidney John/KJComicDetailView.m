//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"
#import "MBProgressHUD.h"

@interface KJComicDetailView ()

@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, strong) NSArray *dirArray;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation KJComicDetailView

@synthesize nameFromList, titleFromList, fileNameFromList, comicImage, comicScrollView;

#pragma mark - UIScrollView delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.comicImage;
}

#pragma mark - NSURLConnection Data delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"COMIC DETAIL: did start receiving data");
    [self.fileData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.fileData writeToFile:self.filePath options:NSAtomicWrite error:Nil] == NO) {
        NSLog(@"COMIC DETAIL: WRITE TO FILE ERROR");
    } else {
        NSLog(@"COMIC DETAIL: FILE WRITTEN");
        // Set image to be displayed
        self.comicImage.image = [UIImage imageWithContentsOfFile:self.filePath];
    }
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Fetch comic image method
- (void)fetchComicImage
{
    self.fileUrl = [NSURL URLWithString:nameFromList];
    
    self.fileData = [NSMutableData data];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[self fileUrl]];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    [conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    
    // Start progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = titleFromList;
    
    //NSLog(@"COMIC DETAIL: name from list - %@", nameFromList);
    
    // Setup scrollview
    self.comicScrollView.delegate = self;
    self.comicScrollView.minimumZoomScale = 1.0;
    self.comicScrollView.maximumZoomScale = 3.0;
    self.comicScrollView.contentSize = self.comicImage.image.size;
    self.comicImage.frame = CGRectMake(0, 0, self.comicImage.image.size.width, self.comicImage.image.size.height);
    
    // Documents folder path
    self.dirArray = [NSArray array];
    self.dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.filePath = [NSString stringWithFormat:@"%@/%@.png", [self.dirArray objectAtIndex:0], fileNameFromList];
    //NSLog(@"%@", [self.dirArray objectAtIndex:0]);
    
    // Check if comic file exists, if not then fetch
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
    if (fileExists) {
        NSLog(@"COMIC DETAIL: comic image file already found, using that");
        self.comicImage.image = [UIImage imageWithContentsOfFile:self.filePath];
    } else {
        NSLog(@"COMIC DETAIL: comic image file NOT found, fetching ..");
        [self fetchComicImage];
    }
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
