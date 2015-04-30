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

// Constant for Core Data attribute to find by
static NSString *kComicAttributeKeyComicName = @"comicName";

@implementation KJComicStore {
    BOOL __block changesToComicsWereMade;
    NSArray __block *existingComicsInCoreDataBeforeFetch;
}

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

- (void)prefetchComicThumbnails {
    // Perform fetch for comics in Core Data
    NSArray *resultsArray = [self fetchExistingComicsInCoreData];
    
    // Init array for doodle image URLs
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    // Loop over comics in results array to get imageURL
    for (KJComic *comic in resultsArray) {
        NSURL *urlToPrefetch = [NSURL fileURLWithPath:[comic returnThumbnailFilepathForComic]];
        
        // Add URL to array
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls
                                                      progress:nil
                                                     completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
                                                         DDLogVerbose(@"comicstore: prefetched comics count: %lu, skipped: %lu", (unsigned long)finishedCount, (unsigned long)skippedCount);
                                                     }];
}

#pragma mark - Return favourite comics method

// Method to return array of comics that have their attribute isFavourite set to YES.
- (NSArray *)returnFavouritesArray {
    // Init predicate for comics where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by comic name)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kComicAttributeKeyComicName
                                                                   ascending:NO];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Set predicate
    fetchRequest.predicate = predicate;
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
        DDLogError(@"comicStore: error fetching favourites: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

#pragma mark - Return comics method

// Method to return all comics in Core Data.
// NOTE - this method won't be around for long, as it's only used for KJComicDetail VC.
// Will be refactoring that view shortly, which then won't need this method.
- (NSArray *)returnComicsArray {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by comic number)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comicNumber"
                                                                   ascending:YES];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
        DDLogError(@"comicStore: error fetching all comics: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

#pragma mark - Core Data helper methods

// Method to check if existing comics in Core Data need updating if values from server have changed since last data fetch.
- (void)checkIfComicNeedsUpdateWithParseObject:(PFObject *)fetchedParseObject {
    // Init strings with values from Parse
    NSString *comicFileName = fetchedParseObject[kParseComicFileNameKey];
    NSString *comicName = fetchedParseObject[kParseComicNameKey];
    NSString *comicNumber = fetchedParseObject[kParseComicNumberKey];
    
    // Init PFFile to get comic file URL
    PFFile *comicFile = fetchedParseObject[kParseComicFileKey];
    NSString *comicFileUrl = comicFile.url;
    
    // Init fetch request for comic matching image URL
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Init predicate for comics matching comic name
    NSPredicate *comicNamePredicate = [NSPredicate predicateWithFormat:@"%@ == %@",
                                       kComicAttributeKeyComicName,
                                       comicName];
    
    // Init predicate for comics in pre-fetched comics array
    NSPredicate *prefetchedComicsPredicate = [NSPredicate predicateWithFormat:@"self IN %@", existingComicsInCoreDataBeforeFetch];
    
    // Init final combined predicate to use
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ comicNamePredicate,
                                                                                   prefetchedComicsPredicate ]];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Set fetch request properties
    fetchRequest.predicate = predicate;
    fetchRequest.entity = entity;
    
    // Execute the fetch
    NSError *error;
    NSArray *comicsInCoreData = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                         error:&error];
    
    // If we found a matching comic
    if ([comicsInCoreData count] > 0) {
        // Checking comics one at a time, so firstObject works here
        KJComic *comicToCheck  = [comicsInCoreData firstObject];
        
        if (![comicToCheck.comicFileName isEqualToString:comicFileName] ||
            ![comicToCheck.comicName isEqualToString:comicName] ||
            ![comicToCheck.comicFileUrl isEqualToString:comicFileUrl] ||
            ![comicToCheck.comicNumber isEqualToString:comicNumber]) {
            DDLogInfo(@"comicStore: comic needs update: %@", comicName);
            
            // Update properties
            comicToCheck.comicFileName = comicFileName;
            comicToCheck.comicName = comicName;
            comicToCheck.comicFileUrl = comicFileUrl;
            comicToCheck.comicNumber = comicNumber;
            
            // Set changes to comics were made property so that we can trigger a managedObjectContext save later.
            // This saves us from triggering a save every time we fetch data from the server.
            changesToComicsWereMade = YES;
        }
        else {
            DDLogInfo(@"comicStore: comic doesn't need update: %@", comicName);
        }
    }
}

// Method to fetch all existing comics in Core Data. We do this before the data fetch to help speed things up.
- (NSArray *)fetchExistingComicsInCoreData {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request for only the video ID property of KJComic
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    
    // Execute the fetch
    NSError *error;
    NSArray *comicsInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if (!comicsInCoreData) {
        // Handle the error
        return nil;
    }
    else {
        return comicsInCoreData;
    }
}

// Method to lazy init existingComicsInCoreDataBeforeFetch array.
- (NSArray *)setupExistingComicsInCoreDataBeforeFetchArray {
    // If we have already init'd, then return existing array
    if (existingComicsInCoreDataBeforeFetch != nil) {
        DDLogInfo(@"comicStore: have already init'd existing comics in Core Data array");
        return existingComicsInCoreDataBeforeFetch;
    }
    
    // Init array with fetchExistingComicsInCoreData method
    existingComicsInCoreDataBeforeFetch = [self fetchExistingComicsInCoreData];
    
    return existingComicsInCoreDataBeforeFetch;
}

// Method to get all image URL strings that exist in Core Data. This helps as we don't have to init a fetch request every time we want to see if something exists in Core Data; we can just check if an image URL exists in the array returned by this method.
- (NSArray *)alreadyFetchedComicNamesArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request for only the image URL property of KJComic
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[ kComicAttributeKeyComicName ];
    
    // Init predicate for pre-fetched existing comics in Core Data array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", existingComicsInCoreDataBeforeFetch];
    request.predicate = predicate;
    
    // Init array for image URL strings
    NSMutableArray *comicNameStrings = [NSMutableArray new];
    
    // Execute the fetch
    NSError *error;
    NSArray *comicsInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if (comicsInCoreData == nil) {
        // Handle the error
        return nil;
    }
    else {
        // Get video ID strings
        for (NSDictionary *dict in comicsInCoreData) {
            NSString *comicName = [dict valueForKey:kComicAttributeKeyComicName];
            [comicNameStrings addObject:comicName];
        }
    }
    
    return [comicNameStrings copy];
}

#pragma mark - Fetch data method

- (void)fetchComicData {
    // Check connection state
    switch (self.connectionState) {
        case KJComicStoreStateConnected:
            DDLogInfo(@"comicStore: we're already connected, so aborting fetchComicData method call");
            return;
            break;
            
        case KJComicStoreStateConnecting:
            DDLogInfo(@"comicStore: we're already connecting, so aborting fetchComicData method call");
            return;
            break;
            
        case KJComicStoreStateDisconnected:
            break;
    }
    
    // Set connection state to CONNECTING
    self.connectionState = KJComicStoreStateConnecting;
    DDLogInfo(@"comicStore: connection state: %lu", (unsigned long)self.connectionState);
    
    // Setup query
    PFQuery *comicsQuery = [PFQuery queryWithClassName:[KJComic parseClassName]];
    
    // Query all comics
    [comicsQuery whereKey:kParseComicNameKey notEqualTo:@"LOL"];
    
    // Cache policy
    //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    // Check for already fetched comics in Core Data
    existingComicsInCoreDataBeforeFetch = [self setupExistingComicsInCoreDataBeforeFetchArray];
    
    // Already fetched comic name strings
    NSArray *alreadyFetchedComicNames = [NSArray arrayWithArray:[self alreadyFetchedComicNamesArray]];
    
    // Start query with block
    [comicsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded
            // Set connection state to CONNECTED
            self.connectionState = KJComicStoreStateConnected;
            DDLogInfo(@"comicStore: connection state: %lu", (unsigned long)self.connectionState);
            
            // Show network activity monitor
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            for (PFObject *object in objects) {
                // Init string for comic name
                NSString *comicName = object[kParseComicNameKey];
                
                if ([object[@"is_active"] isEqual:@"1"]) {
                    
                    // TODO: check if PFFile is already saved on filesystem
                    
                    // Save Parse object to Core Data
                    PFFile *comicImageFile = [object objectForKey:kParseComicFileKey];
                    
                    // If comic doesn't aleady exist locally in Core Data, then create
                    if (![alreadyFetchedComicNames containsObject:comicName]) {
                        DDLogInfo(@"comicStore: haven't fetched comic %@", comicName);
                        
                        // Init new comic
                        KJComic *newComic = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([KJComic class])
                                                                          inManagedObjectContext:self.managedObjectContext];
                        
                        newComic.comicFileName = object[kParseComicFileNameKey];
                        newComic.comicName = object[kParseComicNameKey];
                        newComic.comicFileUrl = comicImageFile.url;
                        newComic.comicNumber = object[kParseComicNumberKey];
                        
                        // Set changes to comics were made property so that we can trigger a managedObjectContext save later.
                        // This saves us from triggering a save every time we fetch data from the server.
                        changesToComicsWereMade = YES;
                    }
                    else {
                        DDLogInfo(@"comicStore: already fetched comic %@", comicName);
                        
                        // Check if comic needs update
                        [self checkIfComicNeedsUpdateWithParseObject:object];
                    }
                }
                
                // Comic is NOT active
                // Check if it exists locally in Core Data, and delete if so
                else {
                    DDLogInfo(@"comicStore: comic not active: %@", object[kParseComicNameKey]);
                    
                    if (![alreadyFetchedComicNames containsObject:comicName]) {
                        DDLogInfo(@"comicStore: comic %@ isn't active but isn't in database, so it's all good", comicName);
                    }
                    
                    // Video IS in Core Data, so delete
                    else {
                        DDLogInfo(@"comicStore: comic %@ isn't active and is in database; deleting now", comicName);
                        
                        // Init fetch request for video to delete
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(%@ == %@)",
                                                  kComicAttributeKeyComicName,
                                                  comicName];
                        fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                                          inManagedObjectContext:self.managedObjectContext];
                        
                        // Execute the fetch
                        NSError *fetchError;
                        NSArray *itemsToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                                          error:&fetchError];
                        
                        // If we found comic to delete ..
                        if ([itemsToDelete count] > 0) {
                            DDLogInfo(@"comicStore: found %lu comic to delete", (unsigned long)[itemsToDelete count]);
                            
                            // Delete
                            KJComic *comicToDelete = [itemsToDelete firstObject];
                            [self.managedObjectContext deleteObject:comicToDelete];
                            
                            // Set changes to comics were made property so that we can trigger a managedObjectContext save later.
                            // This saves us from triggering a save every time we fetch data from the server.
                            changesToComicsWereMade = YES;
                        }
                        else {
                            DDLogError(@"comicStore: failed to find comic to delete from Core Data: %@", comicName);
                        }
                    }
                }
            }
            
            // Save managedObjectContext
            // Only save if we have changes
            if (!changesToComicsWereMade) {
                DDLogInfo(@"comicStore: no changes to comics were found, so no save managedObjectContext is required");
            }
            else {
                // Changes were made.
                // This could have been new comics added, existing comic info updated, or comic deleted from Core Data.
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    // Handle the error.
                    DDLogError(@"comicStore: failed to save managedObjectContext: %@", [error debugDescription]);
                }
                else {
                    DDLogInfo(@"comicStore: saved managedObjectContext");
                }
            }
            
            // Set firstLoad = YES in NSUserDefaults
            if (![NSUserDefaults kj_hasFirstComicFetchCompletedSetting]) {
                [NSUserDefaults kj_setHasFirstComicFetchCompletedSetting:YES];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // Set connection state to DISCONNECTED
            self.connectionState = KJComicStoreStateDisconnected;
            DDLogInfo(@"comicStore: connection state: %lu", (unsigned long)self.connectionState);
            
            // Send NSNotification to say that data fetch is done
            [[NSNotificationCenter defaultCenter] postNotificationName:KJComicDataFetchDidHappenNotification
                                                                object:nil];
            
            // Prefetch comic thumbnails
            // NOTE: does not need to be on wifi as comics are cached locally
            [self prefetchComicThumbnails];
            
        }
        else {
            // Log details of the failure
            DDLogError(@"comicStore: error: %@ %@", error, [error userInfo]);
            // Set connection state to DISCONNECTED
            self.connectionState = KJComicStoreStateDisconnected;
            DDLogInfo(@"comicStore: connection state: %lu", (unsigned long)self.connectionState);
        }
    }];
}

@end
