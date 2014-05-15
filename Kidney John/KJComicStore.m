//
//  KJComicStore.m
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicStore.h"
#import "KJComicFromParse.h"
#import "Parse.h"
#import "SDWebImagePrefetcher.h"

@implementation KJComicStore

#pragma mark - Init methods

+ (KJComicStore *)sharedStore
{
    static KJComicStore *_sharedStore = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJComicStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Prefetch comic thumbnails method

+ (void)prefetchComicThumbnails
{
    NSArray *resultsArray = [[NSArray alloc] init];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    resultsArray = [KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES];
    
    for (KJComic *comic in resultsArray) {
        NSURL *urlToPrefetch = [NSURL fileURLWithPath:[KJComicStore returnThumbnailFilepathForComicObject:comic]];
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls progress:nil completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
        DDLogVerbose(@"comicStore: prefetched comic thumbs count: %d, skipped: %d", finishedCount, skippedCount);
    }];
}

#pragma mark - Comic files on filesystem methods

- (NSArray *)returnComicsFolderAsArray
{
    return [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"];
}

+ (NSString *)returnThumbnailFilepathForComicObject:(KJComic *)comicObject
{
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ComicThumbs"];
    
    // Filepath for jpeg comic thumbs
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg", comicsFolderPath, comicObject.comicNumber];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic thumb file exists");
    } else {
        //DDLogVerbose(@"comicStore: comic thumb file does not exist");
    }
    
    return filePath;
}

+ (NSString *)returnFilepathForComicObject:(KJComic *)comicObject
{
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Comics"];
    
    // Filepath for jpeg comics
    NSString *filePath;
    filePath = [NSString stringWithFormat:@"%@/%@%@.jpg", comicsFolderPath, comicObject.comicNumber, comicObject.comicFileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic file exists");
    } else {
        //DDLogVerbose(@"comicStore: comic file does not exist");
    }
    
    return filePath;
}

+ (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject
{
    // TODO: handle if filepath is nil
    
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnFilepathForComicObject:comicObject]];
    
    DDLogVerbose(@"comicStore: comic image: %@", imageToReturn);
    
    return imageToReturn;
}

+ (UIImage *)returnComicThumbImageFromComicObject:(KJComic *)comicObject
{
    // TODO: handle if filepath is nil
    
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnThumbnailFilepathForComicObject:comicObject]];
    
    DDLogVerbose(@"comicStore: thumb image: %@", imageToReturn);
    
    return imageToReturn;
}

- (NSArray *)returnArrayOfComicFiles
{
    // Load from resources path
    NSMutableArray *comicFileResults = [[NSMutableArray alloc] init];
    
    NSUInteger pngCount = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"] count];
    DDLogVerbose(@"comicStore: bundle count: %d", pngCount);
    
    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"]) {
        //DDLogVerbose(@"%@", fileName);
        [comicFileResults addObject:fileName];
    }
    
    return [NSArray arrayWithArray:comicFileResults];
}

#pragma mark - Comic Favourites methods

+ (void)updateComicFavouriteStatus:(NSString *)comicName isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext]) {
        // Comic is NOT a favourite
        DDLogVerbose(@"Comic is NOT already a favourite, adding now ..");
        
        KJComic *comicToFavourite = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        comicToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        DDLogVerbose(@"comicStore: comic not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfComicIsAFavourite:(NSString *)comicName
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext]) {
        KJComic *comicToFavourite = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        if (!comicToFavourite.isFavourite) {
            DDLogVerbose(@"comicStore: comic IS NOT a favourite");
            return FALSE;
        } else {
            DDLogVerbose(@"comicStore: comic IS a favourite");
            return TRUE;
        }
    } else {
        return FALSE;
    }
}

+ (NSArray *)returnFavouritesArray
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    NSArray *arrayToReturn = [KJComic MR_findAllWithPredicate:predicate inContext:localContext];
    
    return arrayToReturn;
}

#pragma mark - Return comic with comic name method

+ (KJComic *)returnComicWithComicName:(NSString *)comicNameToFind
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find comic where comicNameToFind matches
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comicName == %@", comicNameToFind];
    
    KJComic *comicToReturn = [KJComic MR_findFirstWithPredicate:predicate inContext:localContext];
    
    return comicToReturn;
}

#pragma mark - Core Data methods

+ (BOOL)hasInitialDataFetchHappened
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstComicFetchDone"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkIfComicIsInDatabaseWithName:(NSString *)comicName context:(NSManagedObjectContext *)context
{
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:context]) {
        //DDLogVerbose(@"COMICS LIST: yes, comic does exist in database");
        return TRUE;
    } else {
        //DDLogVerbose(@"COMICS LIST: no, comic does NOT exist in database");
        return FALSE;
    }
}

+ (void)persistNewComicWithName:(NSString *)comicName
                  comicFileName:(NSString *)comicFileName
                   comicFileUrl:(NSString *)comicFileUrl
                    comicNumber:(NSString *)comicNumber
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic does not exist in database then persist
    if (![self checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        // Create a new comic in the current context
        KJComic *newComic = [KJComic MR_createInContext:localContext];
        
        // Set attributes
        newComic.comicName = comicName;
        newComic.comicFileName = comicFileName;
        newComic.comicFileUrl = comicFileUrl;
        newComic.comicNumber = comicNumber;
        
        DDLogVerbose(@"comicStore: saved new comic: %@", comicName);
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)checkIfComicNeedsUpdateWithComicName:(NSString *)comicName
                               comicFileName:(NSString *)comicFileName
                                comicFileUrl:(NSString *)comicFileUrl
                                 comicNumber:(NSString *)comicNumber
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic is in database ..
    if ([KJComicStore checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        KJComic *comicToCheck = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        
        // Check if comicToCheck needs updating
        if (![comicToCheck.comicName isEqualToString:comicName] || ![comicToCheck.comicFileName isEqualToString:comicFileName] || ![comicToCheck.comicFileUrl isEqualToString:comicFileUrl] || ![comicToCheck.comicNumber isEqualToString:comicNumber]) {
            // Comic needs updating
            DDLogVerbose(@"comicStore: comic needs update: %@", comicName);
            
            comicToCheck.comicName = comicName;
            comicToCheck.comicFileName = comicFileName;
            comicToCheck.comicFileUrl = comicFileUrl;
            comicToCheck.comicNumber = comicNumber;
            
            // Save
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    DDLogVerbose(@"comicStore: updated comic: %@", comicName);
                } else if (error) {
                    DDLogError(@"comicStore: error updating comic: %@ - %@", comicName, [error localizedDescription]);
                }
            }];
        }
    }
}

+ (void)fetchComicData
{
    // Setup query
    PFQuery *comicsQuery = [KJComicFromParse query];
    
    // Query all comics
    [comicsQuery whereKey:@"comicName" notEqualTo:@"LOL"];
    
    // Cache policy
    //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    // Start query with block
    [comicsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded
            // Show network activity monitor
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            for (PFObject *object in objects) {
                if ([object[@"is_active"] isEqual:@"1"]) {
                    // TODO:
                    // - check if PFFile is already saved on filesystem
                    
                    // Save Parse object to Core Data
                    PFFile *comicImageFile = [object objectForKey:@"comicFile"];
                    
                    // Check if comic needs updating
                    // NOTE: disabled as app will break if comics are updated
                    //[self checkIfComicNeedsUpdateWithComicName:object[@"comicName"] comicFileName:object[@"comicFileName"] comicFileUrl:comicImageFile.url comicNumber:object[@"comicNumber"]];
                    
                    // Save
                    [self persistNewComicWithName:object[@"comicName"]
                                    comicFileName:object[@"comicFileName"]
                                     comicFileUrl:comicImageFile.url
                                      comicNumber:object[@"comicNumber"]];
                    
                } else {
                    DDLogVerbose(@"comicStore: comic not active: %@", object[@"comicName"]);
                }
            }
            // Send NSNotification to say that data fetch is done
            NSString *notificationName = @"KJComicDataFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            
            // Set firstLoad = YES in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstComicFetchDone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Prefetch comic thumbnails
            // NOTE: does not need to be on wifi as comics are cached locally
            [self prefetchComicThumbnails];
            
        } else {
            // Log details of the failure
            DDLogVerbose(@"comicStore: error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
