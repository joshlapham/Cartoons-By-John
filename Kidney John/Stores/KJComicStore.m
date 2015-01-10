//
//  KJComicStore.m
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicStore.h"
#import "Parse.h"
#import "SDWebImagePrefetcher.h"
#import "NSUserDefaults+KJSettings.h"
#import "KJComic.h"
#import "KJComic+Methods.h"

// Constants for Parse object keys
static NSString *kParseComicNameKey = @"comicName";
static NSString *kParseComicFileKey = @"comicFile";
static NSString *kParseComicFileNameKey = @"comicFileName";
static NSString *kParseComicNumberKey = @"comicNumber";

// Constant for NSNotification name
NSString * const KJComicDataFetchDidHappenNotification = @"KJComicDataFetchDidHappen";

// Constants for comic filepaths
static NSString *kComicThumbnailFilepathFormat = @"%@/%@.jpg";
static NSString *kComicFilepathFormat = @"%@/%@%@.jpg";
static NSString *kComicsLocalDirectoryName = @"Comics";
static NSString *kComicThumbnailsLocalDirectoryName = @"ComicThumbs";

// Constant for Core Data attribute to find by
static NSString *kComicAttributeComicNameKey = @"comicName";

@implementation KJComicStore

#pragma mark - Init method

+ (KJComicStore *)sharedStore {
    static KJComicStore *_sharedStore = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJComicStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Prefetch comic thumbnails method

+ (void)prefetchComicThumbnails {
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[KJComic MR_findAllSortedBy:@"comicNumber" ascending:YES]];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
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

- (NSArray *)returnComicsFolderAsArray {
    return [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                              inDirectory:kComicsLocalDirectoryName];
}

+ (NSString *)returnThumbnailFilepathForComicObject:(KJComic *)comicObject {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicThumbnailsLocalDirectoryName];
    
    // Filepath for jpeg comic thumbs
    NSString *filePath = [NSString stringWithFormat:kComicThumbnailFilepathFormat, comicsFolderPath, comicObject.comicNumber];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic thumb file exists");
    }
    else {
        //DDLogVerbose(@"comicStore: comic thumb file does not exist");
    }
    
    return filePath;
}

+ (NSString *)returnFilepathForComicObject:(KJComic *)comicObject {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicsLocalDirectoryName];
    
    // Filepath for jpeg comics
    NSString *filePath;
    filePath = [NSString stringWithFormat:kComicFilepathFormat, comicsFolderPath, comicObject.comicNumber, comicObject.comicFileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic file exists");
    }
    else {
        //DDLogVerbose(@"comicStore: comic file does not exist");
    }
    
    return filePath;
}

// TODO: do we really need this method?

+ (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject {
    // TODO: handle if filepath is nil
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnFilepathForComicObject:comicObject]];
    
//    DDLogVerbose(@"comicStore: comic image: %@", imageToReturn);
    
    return imageToReturn;
}

+ (UIImage *)returnComicThumbImageFromComicObject:(KJComic *)comicObject {
    // TODO: handle if filepath is nil
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnThumbnailFilepathForComicObject:comicObject]];
    
//    DDLogVerbose(@"comicStore: thumb image: %@", imageToReturn);
    
    return imageToReturn;
}

- (NSArray *)returnArrayOfComicFiles {
    // Load from resources path
    NSMutableArray *comicFileResults = [[NSMutableArray alloc] init];
    
    NSUInteger pngCount = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                                              inDirectory:kComicsLocalDirectoryName] count];
    DDLogVerbose(@"comicStore: bundle count: %d", pngCount);
    
    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:kComicsLocalDirectoryName]) {
        //DDLogVerbose(@"%@", fileName);
        [comicFileResults addObject:fileName];
    }
    
    return [NSArray arrayWithArray:comicFileResults];
}

#pragma mark - Comic Favourites methods

// TODO: add init NSPredicate method using propety in this method, then refactor this method out

+ (NSArray *)returnFavouritesArray {
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    NSArray *arrayToReturn = [KJComic MR_findAllWithPredicate:predicate inContext:localContext];
    
    return arrayToReturn;
}

#pragma mark - Return comic with comic name method

// TODO: add init NSPredicate method using propety in this method, then refactor this method out

+ (KJComic *)returnComicWithComicName:(NSString *)comicNameToFind {
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find comic where comicNameToFind matches
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comicName == %@", comicNameToFind];
    
    KJComic *comicToReturn = [KJComic MR_findFirstWithPredicate:predicate inContext:localContext];
    
    return comicToReturn;
}

#pragma mark - Core Data methods

// TODO: do we really need this method? Can just check Core Data for KJComic object elsewhere

+ (BOOL)checkIfComicIsInDatabaseWithName:(NSString *)comicName context:(NSManagedObjectContext *)context {
    if ([KJComic MR_findFirstByAttribute:kComicAttributeComicNameKey withValue:comicName inContext:context]) {
        //DDLogVerbose(@"COMICS LIST: yes, comic does exist in database");
        return TRUE;
    }
    else {
        //DDLogVerbose(@"COMICS LIST: no, comic does NOT exist in database");
        return FALSE;
    }
}

// TODO: do we really need this method? Refactor

+ (void)persistNewComicWithName:(NSString *)comicName
                  comicFileName:(NSString *)comicFileName
                   comicFileUrl:(NSString *)comicFileUrl
                    comicNumber:(NSString *)comicNumber {
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic does not exist in database then persist
    if (![self checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        
        // Init new comic object in localContext
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

// TODO: not even calling this method at the moment, review this

- (void)checkIfComicNeedsUpdateWithComicName:(NSString *)comicName
                               comicFileName:(NSString *)comicFileName
                                comicFileUrl:(NSString *)comicFileUrl
                                 comicNumber:(NSString *)comicNumber {
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic is in database ..
    if ([KJComicStore checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        
        // Init comic object
        KJComic *comicToCheck = [KJComic MR_findFirstByAttribute:kComicAttributeComicNameKey
                                                       withValue:comicName
                                                       inContext:localContext];
        
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
                }
                else if (error) {
                    DDLogError(@"comicStore: error updating comic: %@ - %@", comicName, [error localizedDescription]);
                }
            }];
        }
    }
}

// TODO: do we really need this method?

+ (void)deleteComicFromDatabaseWithComicName:(NSString *)comicName {
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // NOTE - we're not checking if comic is in database first (as  the checkIfComicNeedsUpdate method does),
    // we're doing that before calling this method, just so it's a bit more clear what we're doing in the fetchComicData method
    
    // Init comic object
    KJComic *comicToDelete = [KJComic MR_findFirstByAttribute:kComicAttributeComicNameKey
                                                    withValue:comicName
                                                    inContext:localContext];
    
    if (comicToDelete) {
        // Delete object
        [comicToDelete MR_deleteInContext:localContext];
        
        // Save
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogVerbose(@"comicStore: deleted comic");
            }
            else if (error) {
                DDLogError(@"comicStore: error deleting comic: %@", [error localizedDescription]);
            }
        }];
    }
}

+ (void)fetchComicData
{
    // Setup query
    PFQuery *comicsQuery = [PFQuery queryWithClassName:[KJComic parseClassName]];
    
    // Query all comics
    [comicsQuery whereKey:kParseComicNameKey notEqualTo:@"LOL"];
    
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
                    PFFile *comicImageFile = [object objectForKey:kParseComicFileKey];
                    
                    // Check if comic needs updating
                    // NOTE: disabled as app will break if comics are updated
                    //[self checkIfComicNeedsUpdateWithComicName:object[@"comicName"] comicFileName:object[@"comicFileName"] comicFileUrl:comicImageFile.url comicNumber:object[@"comicNumber"]];
                    
                    // Save
                    [self persistNewComicWithName:object[kParseComicNameKey]
                                    comicFileName:object[kParseComicFileNameKey]
                                     comicFileUrl:comicImageFile.url
                                      comicNumber:object[kParseComicNumberKey]];
                    
                }
                else {
                    DDLogVerbose(@"comicStore: comic not active: %@", object[kParseComicNameKey]);
                    
                    // Check if comic exists in database, and delete if so
                    BOOL existInDatabase = [self checkIfComicIsInDatabaseWithName:object[kParseComicNameKey]
                                                                          context:[NSManagedObjectContext MR_contextForCurrentThread]];
                    
                    if (existInDatabase) {
                        DDLogVerbose(@"comicStore: comic %@ exists in database but is no longer active on server; now removing", object[kParseComicNameKey]);
                        [self deleteComicFromDatabaseWithComicName:object[kParseComicNameKey]];
                    }
                }
            }
            
            // Send NSNotification to say that data fetch is done
            [[NSNotificationCenter defaultCenter] postNotificationName:KJComicDataFetchDidHappenNotification
                                                                object:nil];
            
            // Set firstLoad = YES in NSUserDefaults
            if (![NSUserDefaults kj_hasFirstComicFetchCompletedSetting]) {
                [NSUserDefaults kj_setHasFirstComicFetchCompletedSetting:YES];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // Prefetch comic thumbnails
            // NOTE: does not need to be on wifi as comics are cached locally
            [self prefetchComicThumbnails];
            
        }
        else {
            // Log details of the failure
            DDLogError(@"comicStore: error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
