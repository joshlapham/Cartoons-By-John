//
//  KJComicListView.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicListView.h"
#import "KJComicCell.h"
#import "KJComicDetailView.h"
#import "Parse.h"
#import "Models/KJComic.h"
#import "Models/KJComicFromParse.h"
#import "MBProgressHUD.h"

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *comicImages;
@property (nonatomic, strong) NSArray *comicThumbImages;
@property (nonatomic, strong) NSArray *comicResults;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong) NSURL *fileUrl;

@end

@implementation KJComicListView

@synthesize comicResults;

#pragma mark - Core Data did finish loading NSNotification
- (void)comicDataFetchDidHappen
{
    NSLog(@"DID RECEIVE NOTIFICATION THAT COMIC THUMBNAIL FETCH IS DONE");
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAll];
    
    // Reload collectionview with data just fetched
    [[self collectionView] reloadData];
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Core Data methods
- (BOOL)checkIfComicIsInDatabaseWithName:(NSString *)comicName context:(NSManagedObjectContext *)context
{
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:context]) {
        NSLog(@"Yes, comic does exist in database");
        return TRUE;
    } else {
        NSLog(@"No, comic does NOT exist in database");
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
        
        // DEBUGGING
        NSLog(@"CORE DATA: %@", newComic.comicData);
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Fetch videos method
- (void)callFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *query = [KJComicFromParse query];
        
        // Query all videos
        [query whereKey:@"comicName" notEqualTo:@"LOL"];
        
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
                            
                            NSString *notificationName = @"KJComicDataFetchDidHappen";
                            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
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
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"comicLoadDone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark - UICollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"COMIC LIST: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"comicDetailSegue" sender:self];
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self comicResults] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    KJComic *comicCell = [comicResults objectAtIndex:indexPath.row];
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        UIImage *thumbImage = [UIImage imageWithData:comicCell.comicThumbData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor whiteColor];
//            [cell setThumbImage:thumbImagePath];
            cell.comicImageView.image = thumbImage;
        });
    });
    
    return cell;
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        KJComic *comicCell = [comicResults objectAtIndex:selectedIndexPath.row];
        destViewController.nameFromList = comicCell.comicData;
        destViewController.titleFromList = comicCell.comicName;
        destViewController.fileNameFromList = comicCell.comicFileName;
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Comix";
    
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];

    // Register for notification when data fetch to Core Data has completed
    NSString *notificationName = @"KJComicDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(comicDataFetchDidHappen)
                                                 name:notificationName
                                               object:nil];
    
    // If data fetch hasn't happened then proceed
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"comicLoadDone"] isEqualToString:@"1"]) {
        NSLog(@"COMIC LIST: data fetch has already happened, assuming data is local in Core Data");
        comicResults = [[NSArray alloc] init];
        comicResults = [KJComic MR_findAll];
    } else {
        // Start progress
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"";
        
        [self callFetchMethod];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.comicThumbImages = nil;
}

@end
