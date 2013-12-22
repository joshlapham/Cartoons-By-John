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

@interface KJComicDetailView () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, strong) NSArray *dirArray;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation KJComicDetailView

@synthesize nameFromList, titleFromList, fileNameFromList, comicImage, comicScrollView;

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
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
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
    hud.labelText = @"Loading comic ...";
    
    // Show network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = titleFromList;
    
    // TESTING - navbar title
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor blackColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = titleFromList;
    self.navigationItem.titleView = navLabel;
    // END OF TESTING
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
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
