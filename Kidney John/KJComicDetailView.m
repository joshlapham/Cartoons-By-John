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
#import "KJComicCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KJComicDetailView () <UIActionSheetDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJComicDetailView {
    NSMutableData *fileData;
    NSURL *fileUrl;
    NSArray *dirArray;
    NSString *filePath;
    float expectedLength;
    float currentLength;
    SDWebImageManager *webImageManager;
}

@synthesize nameFromList, titleFromList, fileNameFromList, comicImage, comicScrollView, hud, resultsArray;

#pragma mark - UICollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"count for coll. view - %d", [self.resultsArray count]);
    return [[self resultsArray] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicDetailCell" forIndexPath:indexPath];
    
    KJComic *cellData = [self.resultsArray objectAtIndex:indexPath.row];
    
    // set title to comic
    // TODO: title to be set only after cell has finished loading
    self.title = cellData.comicName;
    
    //NSLog(@"comic name: %@", cellData.comicName);
    //NSLog(@"cell for item results array count: %d", [self.resultsArray count]);
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.comicData]) {
        //NSLog(@"found image in cache");
    } else {
        //NSLog(@"no image in cache");
    }
    
    [webImageManager downloadWithURL:[NSURL URLWithString:cellData.comicData]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                //NSLog(@"video thumb download: %d of %d downloaded", receivedSize, expectedSize);
                            }
                           completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                               if (cellImage && finished) {
                                   cell.comicImageView.image = cellImage;
                               } else {
                                   NSLog(@"comic download error");
                               }
                           }];
    
//    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(defaultQueue, ^{
//        UIImage *thumbImage = [UIImage imageWithData:cellData.comicFileData];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.backgroundColor = [UIColor whiteColor];
//            cell.comicImageView.image = thumbImage;
//        });
//    });
//    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

#pragma mark - setup collection view method

- (void)setupCollectionView
{
    [self.collectionView setBounds:self.view.frame];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // use up whole screen (or frame)
    //[flowLayout setItemSize:self.collectionView.frame.size];
    
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // scroll to same position in the collectionView
    // as we were on the previous view controller
    if (self.collectionViewIndexFromList != nil) {
        [self.collectionView scrollToItemAtIndexPath:self.collectionViewIndexFromList atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    [self.collectionView reloadData];
}

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
    // TODO: run on background thread?
    [conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [conn start];
    
    // Start progress
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Loading comic ...";
    
    // Show network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - Gesture recognizer methods

- (void)comicWasDoubleTapped
{
    NSLog(@"comic was double tapped");
    
    // Navbar
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - image download and caching method

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"results array count: %d", [self.resultsArray count]);
    
    // Set title
    // DISABLED as we set the title in cellAtIndexPath method
    //self.title = titleFromList;
    
    // init SDWebImage cache manager
    webImageManager = [SDWebImageManager sharedManager];
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicDetailCell"];
    
    [self setupCollectionView];
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    
    // Hide navbar
    self.navigationController.navigationBarHidden = YES;
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    // Gesture recognizer to show navbar when comic is double tapped
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comicWasDoubleTapped)];
    tapRecognizer.numberOfTapsRequired = 2;
    //tapRecognizer.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:tapRecognizer];
    
//    // Documents folder path
//    dirArray = [NSArray array];
//    dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    filePath = [NSString stringWithFormat:@"%@/%@.png", [dirArray objectAtIndex:0], fileNameFromList];
//    //NSLog(@"%@", [self.dirArray objectAtIndex:0]);
//    
//    // Check if comic file exists, if not then fetch
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    if (fileExists) {
//        NSLog(@"COMIC DETAIL: comic image file already found, using that");
//        self.comicImage.image = [UIImage imageWithContentsOfFile:filePath];
//    } else {
//        NSLog(@"COMIC DETAIL: comic image file NOT found, fetching ..");
//        [self fetchComicImage];
//    }
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

- (void)viewDidLayoutSubviews
{
    //[self.collectionView reloadData];
}

@end
