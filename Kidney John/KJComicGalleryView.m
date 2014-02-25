//
//  KJComicGalleryView.m
//  Kidney John
//
//  Created by jl on 29/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicGalleryView.h"
#import "MWPhotoBrowser.h"
#import "Models/KJComic.h"
#import "Parse.h"
#import "Models/KJComicFromParse.h"
#import "MBProgressHUD.h"

@interface KJComicGalleryView () <MWPhotoBrowserDelegate, UIActionSheetDelegate>

@end

@implementation KJComicGalleryView {
    NSArray *comicResults;
    NSMutableArray *comicThumbResults;
    NSMutableArray *comicsForBrowser;
    MWPhotoBrowser *browser;
}

#pragma mark - Set up browser methods

- (void)setupComicsBrowser
{
    NSLog(@"Setting up comics browser gallery ...");
    
    // Create browser
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // TESTING - navbar colour
    //browser.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
    
    // Set options
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.startOnGrid = YES;
    browser.zoomPhotosToFill = YES;
    //[browser setCurrentPhotoIndex:0];
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading comix ...";
    
    [self callComicsFetchMethod];
}

- (void)fetchComicsForBrowser
{
    NSLog(@"Fetching comics for browser ...");
    
    // Init comics array with results from Core Data
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAll];
    comicsForBrowser = [[NSMutableArray alloc] init];
    
    for (KJComic *comic in comicResults) {
        // NOTE - using thumbnails for now
        // would have to check filepath for full-size comics
        // refer to KJComicListView for filepath checking
        
        //NSURL *comicDataUrl = [NSURL URLWithString:comic.comicData];
        //NSData *comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
        [comicsForBrowser addObject:[MWPhoto photoWithImage:[UIImage imageWithData:comic.comicFileData]]];
        NSLog(@"comic file name: %@", comic.comicFileName);
    }
    
    NSLog(@"comicsForBrowser array count: %lu", (unsigned long)[comicsForBrowser count]);
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self reloadBrowserDataAndPresentBrowser];
    
    // TODO:
    // send a notification once fetch is complete
    // in that notification selector method, call reloadBrowserDataAndPresentBrowser
}

- (void)reloadBrowserDataAndPresentBrowser
{
    NSLog(@"now reloading browser data ...");
    
    [browser reloadData];
    
    // Present browser
    [self addChildViewController:browser];
    //self.tabBarController.tabBar.hidden = YES;
    [[self view] addSubview:[browser view]];
    [browser didMoveToParentViewController:self];
}

#pragma mark - MWPhotoBrowser delegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    // return comics array count
    return comicsForBrowser.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < comicsForBrowser.count) {
        return [comicsForBrowser objectAtIndex:index];
    } else {
        return nil;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < comicsForBrowser.count) {
        return [comicsForBrowser objectAtIndex:index];
    } else {
        return nil;
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index
{
    //[self.tabBarController.tabBar setHidden:YES];
    //self.tabBarController.hidesBottomBarWhenPushed = YES;
    
    //NSLog(@"DEBUG: my view controller is: %@", [[self view] class]);
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    //NSString *other2 = @"Share on Facebook";
    //NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    //NSString *actionSheetTitle = @"Action";
    //NSString *destructiveTitle = @"Destructive button";
    
    // Set Favourites button text accordingly
    // NOTE - this needs to be reviewed
    // Current just setting this to 'Add to Favourites' for testing purposes
//    if (![self checkIfComicIsAFavourite:titleFromList]) {
//        favouritesString = @"Add to Favourites";
//    } else {
//        favouritesString = @"Remove from Favourites";
//    }
    favouritesString = @"Add to Favourites";
    
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
    
    // NOTE - to be reviewed
    // reused code from another class
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        //[self updateComicFavouriteStatus:titleFromList isFavourite:YES];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        //[self updateComicFavouriteStatus:titleFromList isFavourite:NO];
    } else if ([buttonPressed isEqualToString:@"Share on Twitter"]) {
        NSLog(@"ACTION SHEET: share on twitter button pressed");
        //[self postToTwitter];
    } else if ([buttonPressed isEqualToString:@"Share on Facebook"]) {
        NSLog(@"ACTION SHEET: share on facebook button pressed");
        //[self postToFacebook];
    }
}

#pragma mark - Init methods

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navbar title label init
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    //self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    // Set title text colour
    navLabel.textColor = [UIColor whiteColor];
    // Set title
    navLabel.text = @"Comix";
    self.navigationItem.titleView = navLabel;
    
    // Hide the status bar
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // TESTING
    [[self navigationController] setHidesBottomBarWhenPushed:YES];
    
    [self setupComicsBrowser];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //[self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - Core Data methods

- (BOOL)checkIfComicIsInDatabaseWithName:(NSString *)comicName context:(NSManagedObjectContext *)context
{
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:context]) {
        //NSLog(@"COMICS LIST: yes, comic does exist in database");
        return TRUE;
    } else {
        //NSLog(@"COMICS LIST: no, comic does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewComicWithName:(NSString *)comicName
                      comicData:(NSString *)comicData
                 comicThumbData:(NSData *)comicThumbData
                  comicFileName:(NSString *)comicFileName
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic does not exist in database then persist
    if (![self checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        // Create a new comic in the current context
        KJComic *newComic = [KJComic MR_createInContext:localContext];
        
        // Set attributes
        newComic.comicName = comicName;
        newComic.comicData = comicData;
        newComic.comicThumbData = comicThumbData;
        newComic.comicFileName = comicFileName;
        
        // Set comic file data from comicData string
        NSURL *comicDataUrl = [NSURL URLWithString:comicData];
        newComic.comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
        
        // DEBUGGING
        NSLog(@"CORE DATA: %@", newComic.comicData);
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)callComicsFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"COMICS PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *comicsQuery = [KJComicFromParse query];
        
        // Query all videos
        [comicsQuery whereKey:@"comicName" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [comicsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        //[self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                        PFFile *thumbImageFile = [object objectForKey:@"comicThumb"];
                        PFFile *comicImageFile = [object objectForKey:@"comicFile"];
                        
                        //NSLog(@"COMIC LIST: PFFile URL: %@", thumbImageFile.url);
                        [thumbImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                [self persistNewComicWithName:object[@"comicName"]
                                                    comicData:comicImageFile.url
                                               comicThumbData:data
                                                comicFileName:object[@"comicFileName"]];
                            }
                            //[self.collectionView reloadData];
                            
                            //NSString *notificationName = @"KJComicDataFetchDidHappen";
                            //[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
                        }];
                        
                    } else {
                        NSLog(@"COMIC LIST: comic not active: %@", object[@"comicName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"comicLoadDone"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            
            [self fetchComicsForBrowser];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"COMICS PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

@end
