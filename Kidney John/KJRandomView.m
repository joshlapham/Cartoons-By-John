//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "Parse.h"
#import "Models/KJRandomImageFromParse.h"
#import "MBProgressHUD.h"
#import "Models/KJRandomImage.h"

@interface KJRandomView ()

@property (nonatomic, strong) NSString *currentRandomImageUrl;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) __block NSArray *randomImagesResults;

@end

@implementation KJRandomView

@synthesize randomImage, randomImagesResults;

#pragma mark - Core Data did finish loading NSNotification
- (void)randomImageFetchDidHappen
{
    NSLog(@"DID RECEIVE NOTIFICATION THAT RANDOM IMAGE FETCH IS DONE");
    randomImagesResults = [[NSArray alloc] init];
    randomImagesResults = [KJRandomImage MR_findAll];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
    
    //[[self tableView] reloadData];
}

#pragma mark - Core Data methods
- (BOOL)checkIfRandomImageIsInDatabaseWithImageUrl:(NSString *)imageUrl context:(NSManagedObjectContext *)context
{
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:context]) {
        NSLog(@"Yes, random image does exist in database");
        return TRUE;
    } else {
        NSLog(@"No, random image does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewRandomImageWithId:(NSString *)imageId
                  description:(NSString *)imageDescription
                         url:(NSString *)imageUrl
                   date:(NSString *)imageDate
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If video does not exist in database then persist
    if (![self checkIfRandomImageIsInDatabaseWithImageUrl:imageUrl context:localContext]) {
        // Create a new video in the current context
        KJRandomImage *newRandomImage = [KJRandomImage MR_createInContext:localContext];
        
        // Set attributes
        newRandomImage.imageId = imageId;
        newRandomImage.imageDescription = imageDescription;
        newRandomImage.imageUrl = imageUrl;
        //newRandomImage.imageDate = imageDate;
        // Thumbnails
        //NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", videoId];
        NSURL *imageUrlToFetch = [NSURL URLWithString:imageUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrlToFetch];
        newRandomImage.imageData = imageData;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Parse.com fetch method
- (void)callFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *query = [KJRandomImageFromParse query];
        
        // Query all videos
        [query whereKey:@"imageUrl" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        //[self persis:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                        [self persistNewRandomImageWithId:object[@"imageId"] description:object[@"imageDescription"] url:object[@"imageUrl"] date:object[@"date"]];
                    } else {
                        NSLog(@"RANDOM IMAGES: image not active: %@", object[@"imageUrl"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set randomImagesFetchDone = YES in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"randomImagesFetchDone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *notificationName = @"KJRandomImageFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            
            // set imageview here
            //self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark - Return random image from an array
- (UIImage *)getRandomImageFromArray:(NSArray *)arrayToCheck
{
    NSString *stringToReturn = [[NSString alloc] init];
    UIImage *imageToReturn;
    
    // Get random URL if it wasn't just displayed
    do {
        NSUInteger randomIndex = arc4random() % [arrayToCheck count];
        //stringToReturn = [NSString stringWithFormat:@"%@", [arrayToCheck objectAtIndex:randomIndex]];
        KJRandomImage *returnedRandomImage = [arrayToCheck objectAtIndex:randomIndex];
        stringToReturn = returnedRandomImage.imageUrl;
        imageToReturn = [UIImage imageWithData:returnedRandomImage.imageData];
    } while ([stringToReturn isEqualToString:self.currentRandomImageUrl]);
    
    // Set last URL variable to the URL string we're using
    self.currentRandomImageUrl = stringToReturn;
    
    return imageToReturn;
}

#pragma mark - UISwipeGesture method
- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"RANDOM: swipe received");
    if ([randomImagesResults count] != 0) {
        self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
    } else {
        NSLog(@"RANDOM: error - swipeHandler could not load an image due to an empty image URL array");
    }
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Doodles";
    
    // Init swipe gesture recognizer for image view
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.randomImage addGestureRecognizer:self.gestureRecognizer];
    
    // Register for notification when data fetch to Core Data has completed
    NSString *notificationName = @"KJRandomImageFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(randomImageFetchDidHappen) name:notificationName object:nil];
    
    // If data fetch hasn't happened then proceed
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"randomImagesFetchDone"] isEqualToString:@"1"]) {
        NSLog(@"RANDOM: data fetch has already happened, assuming data is local in Core Data");
        randomImagesResults = [[NSArray alloc] init];
        randomImagesResults = [KJRandomImage MR_findAll];
        
        self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
    } else {
        // Start progress
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"";
        
        [self callFetchMethod];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
//    if ([[self imageUrlResults] count] != 0) {
//        self.randomImage.image = [self getRandomImageFromArray];
//    } else {
//        NSLog(@"RANDOM: error - viewWillAppear could not load an image due to an empty image URL array");
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //self.randomImage.image = nil;
    
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.randomImage.image = nil;
    //self.imageUrlResults = nil;
}

@end
