//
//  KJComicDetailView.m
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicDetailView.h"
#import "MBProgressHUD.h"
#import "Models/KJComic.h"

@interface KJComicDetailView () <UIActionSheetDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation KJComicDetailView {
    NSMutableData *fileData;
    NSURL *fileUrl;
    NSArray *dirArray;
    NSString *filePath;
    float expectedLength;
    float currentLength;
}

@synthesize nameFromList, titleFromList, fileNameFromList, comicImage, comicScrollView, hud;

#pragma mark - Comic Favourites methods

- (void)updateComicFavouriteStatus:(NSString *)comicName isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Create a new video in the current context
    //KJVideo *newVideo = [KJVideo MR_createInContext:localContext];
    
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext]) {
        //NSLog(@"Video is NOT already a favourite, adding now ..");
        
        KJComic *comicToFavourite = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        comicToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        NSLog(@"Video not found in database, not adding anything to favourites");
    }
}

- (BOOL)checkIfComicIsAFavourite:(NSString *)comicName
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext]) {
        KJComic *comicToFavourite = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        if (!comicToFavourite.isFavourite) {
            NSLog(@"Comic IS NOT a favourite");
            return FALSE;
        } else {
            NSLog(@"Comic IS a favourite");
            return TRUE;
        }
    } else {
        return FALSE;
    }
}

#pragma mark - Show UIActionSheet method

- (void)showActionSheet:(id)sender
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    //NSString *other2 = @"Share on Facebook";
    //NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    //NSString *actionSheetTitle = @"Action";
    //NSString *destructiveTitle = @"Destructive button";
    
    // Set Favourites button text accordingly
    if (![self checkIfComicIsAFavourite:titleFromList]) {
        favouritesString = @"Add to Favourites";
    } else {
        favouritesString = @"Remove from Favourites";
    }
    
    // Init action sheet with Favourites and Share buttons
    // NOTE - no FB/Twitter share is enabled for Comics right now
    //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, other2, other3, nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, nil];
    
    // Add action sheet to view, taking in consideration the tab bar
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        [self updateComicFavouriteStatus:titleFromList isFavourite:YES];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        [self updateComicFavouriteStatus:titleFromList isFavourite:NO];
    } else if ([buttonPressed isEqualToString:@"Share on Twitter"]) {
        NSLog(@"ACTION SHEET: share on twitter button pressed");
        //[self postToTwitter];
    } else if ([buttonPressed isEqualToString:@"Share on Facebook"]) {
        NSLog(@"ACTION SHEET: share on facebook button pressed");
        //[self postToFacebook];
    }
}

#pragma mark - UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.comicImage;
}

#pragma mark - NSURLConnection Data delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"COMIC DETAIL: did start receiving data");
    [fileData appendData:data];
    
    // Set HUD progress as data is received
    currentLength += [data length];
    hud.progress = currentLength / expectedLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Init variables used to track comic download progress for HUD
    expectedLength = [response expectedContentLength];
    currentLength = 0;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([fileData writeToFile:filePath options:NSAtomicWrite error:Nil] == NO) {
        NSLog(@"COMIC DETAIL: WRITE TO FILE ERROR");
    } else {
        NSLog(@"COMIC DETAIL: FILE WRITTEN");
        // Set image to be displayed
        //comicImage.frame = self.comicScrollView.bounds;
        comicImage.image = [UIImage imageWithContentsOfFile:filePath];
        [self.comicScrollView addSubview:self.comicImage];
        [self centerScrollViewContents];
    }
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - ScrollView methods

- (void)centerScrollViewContents {
    CGSize boundsSize = self.comicScrollView.bounds.size;
    CGRect contentsFrame = self.comicImage.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.comicImage.frame = contentsFrame;
}

#pragma mark - Fetch comic image method

- (void)fetchComicImage
{
    fileUrl = [NSURL URLWithString:nameFromList];
    
    fileData = [NSMutableData data];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:fileUrl];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    [conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    
    // Start progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Loading comic ...";
    
    // Show network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = titleFromList;
    
    // Init navbar title label
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = titleFromList;
    self.navigationItem.titleView = navLabel;
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
    //NSLog(@"COMIC DETAIL: name from list - %@", nameFromList);
    
    // Setup scrollview
    self.comicScrollView.delegate = self;
    self.comicScrollView.minimumZoomScale = 1.0;
    self.comicScrollView.maximumZoomScale = 3.0;
    self.comicScrollView.contentSize = self.comicImage.image.size;
    
//    CGRect contentRect = CGRectZero;
//    for (UIView *view in self.comicScrollView.subviews) {
//        contentRect = CGRectUnion(contentRect, view.frame);
//    }
//    self.comicScrollView.contentSize = contentRect.size;
    
    self.comicImage.frame = CGRectMake(0, 0, self.comicImage.image.size.width, self.comicImage.image.size.height);
    
    // Documents folder path
    dirArray = [NSArray array];
    dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filePath = [NSString stringWithFormat:@"%@/%@.png", [dirArray objectAtIndex:0], fileNameFromList];
    //NSLog(@"%@", [self.dirArray objectAtIndex:0]);
    
    // Check if comic file exists, if not then fetch
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSLog(@"COMIC DETAIL: comic image file already found, using that");
        self.comicImage.image = [UIImage imageWithContentsOfFile:filePath];
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
