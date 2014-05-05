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

@implementation KJComicStore {
    NSString *filePath;
}

#pragma mark - Comic files on filesystem methods

- (NSArray *)returnComicsFolderAsArray
{
    return [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"];
}

- (NSString *)returnThumbnailFilepathForComicObject:(KJComic *)comicObject
{
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ComicThumbs"];
    
    // Filepath for jpeg comic thumbs
    filePath = [NSString stringWithFormat:@"%@/%@.jpg", comicsFolderPath, comicObject.comicNumber];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        NSLog(@"comicStore: comic thumb file exists");
    } else {
        NSLog(@"comicStore: comic thumb file does not exist");
    }
    
    return filePath;
}

- (NSString *)returnFilepathForComicObject:(KJComic *)comicObject
{
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Comics"];
    
    // Filepath for jpeg comics
    filePath = [NSString stringWithFormat:@"%@/%@%@.jpg", comicsFolderPath, comicObject.comicNumber, comicObject.comicFileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
    if (fileExists) {
        NSLog(@"comicStore: comic file exists");
    } else {
        NSLog(@"comicStore: comic file does not exist");
    }
    
    return filePath;
}

- (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject
{
    // TODO: handle if filepath is nil
    
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnFilepathForComicObject:comicObject]];
    
    NSLog(@"comicStore: comic image: %@", imageToReturn);
    
    return imageToReturn;
}

- (UIImage *)returnComicThumbImageFromComicObject:(KJComic *)comicObject
{
    // TODO: handle if filepath is nil
    
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnThumbnailFilepathForComicObject:comicObject]];
    
    NSLog(@"comicStore: thumb image: %@", imageToReturn);
    
    return imageToReturn;
}

- (NSArray *)returnArrayOfComicFiles
{
    // load from resources path
    NSMutableArray *comicFileResults = [[NSMutableArray alloc] init];
    
    NSUInteger pngCount = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"] count];
    NSLog(@"comicStore: bundle count: %d", pngCount);
    
    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"]) {
        //NSLog(@"%@", fileName);
        [comicFileResults addObject:fileName];
    }
    
    return [NSArray arrayWithArray:comicFileResults];
}

#pragma mark - Comic Favourites methods

+ (void)updateComicFavouriteStatus:(NSString *)comicName isFavourite:(BOOL)isOrNot
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
        NSLog(@"comicStore: comic not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfComicIsAFavourite:(NSString *)comicName
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext]) {
        KJComic *comicToFavourite = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        if (!comicToFavourite.isFavourite) {
            NSLog(@"comicStore: comic IS NOT a favourite");
            return FALSE;
        } else {
            NSLog(@"comicStore: comic IS a favourite");
            return TRUE;
        }
    } else {
        return FALSE;
    }
}

#pragma mark - return comic with comic name method

+ (KJComic *)returnComicWithComicName:(NSString *)comicNameToFind
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find comic where comicNameToFind matches
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comicName == %@", comicNameToFind];
    KJComic *comicToReturn = [KJComic MR_findFirstWithPredicate:predicate inContext:localContext];
    
    //NSLog(@"comic store: comic to return: %@", comicToReturn.comicName);
    
    return comicToReturn;
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
                 comicFileData:(NSData *)comicFileData
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
        //newComic.comicFileData = comicFileData;
        newComic.comicFileName = comicFileName;
        newComic.comicFileUrl = comicFileUrl;
        newComic.comicNumber = comicNumber;
        
        // Set comic file data from comicData string
        // DISABLED as we are using SDWebImage for comic image caching
//            NSURL *comicDataUrl = [NSURL URLWithString:comicData];
//            newComic.comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
        
        NSLog(@"comicStore: saved new comic: %@", comicName);
        
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
    if ([self checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        KJComic *comicToCheck = [KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:localContext];
        
        // Check if comicToCheck needs updating
        if (![comicToCheck.comicName isEqualToString:comicName] || ![comicToCheck.comicFileName isEqualToString:comicFileName] || ![comicToCheck.comicFileUrl isEqualToString:comicFileUrl] || ![comicToCheck.comicNumber isEqualToString:comicNumber]) {
            // Comic needs updating
            NSLog(@"comicStore: comic needs update: %@", comicName);
            
            comicToCheck.comicName = comicName;
            comicToCheck.comicFileName = comicFileName;
            comicToCheck.comicFileUrl = comicFileUrl;
            comicToCheck.comicNumber = comicNumber;
            
            // Save
            //[localContext MR_saveToPersistentStoreAndWait];
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"comicStore: updated comic: %@", comicName);
                } else if (error) {
                    NSLog(@"comicStore: error updating comic: %@ - %@", comicName, [error localizedDescription]);
                }
            }];
        }
    }
}

- (void)fetchComicData
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
            // The find succeeded.
            // Do something with the found objects
            
            // Show network activity monitor
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            for (PFObject *object in objects) {
                if ([object[@"is_active"] isEqual:@"1"]) {
                    // TODO:
                    // - check if PFFile is already saved on filesystem
                    
                    // Save Parse object to Core Data
                    //PFFile *thumbImageFile = [object objectForKey:@"comicThumb"];
                    PFFile *comicImageFile = [object objectForKey:@"comicFile"];
                    
                    // Check if comic needs updating
                    // NOTE: disabled as app will break if comics are updated
                    //[self checkIfComicNeedsUpdateWithComicName:object[@"comicName"] comicFileName:object[@"comicFileName"] comicFileUrl:comicImageFile.url comicNumber:object[@"comicNumber"]];
                    
                    // Save
                    [self persistNewComicWithName:object[@"comicName"]
                                    comicFileData:nil
                                    comicFileName:object[@"comicFileName"]
                                     comicFileUrl:comicImageFile.url
                                      comicNumber:object[@"comicNumber"]];
                    
                    //NSLog(@"COMIC LIST: PFFile URL: %@", thumbImageFile.url);
//                        [comicImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                            if (!error) {
//                                [self persistNewComicWithName:object[@"comicName"]
//                                               comicFileData:data
//                                                comicFileName:object[@"comicFileName"]
//                                                 comicFileUrl:comicImageFile.url];
//                            }
//                        }];
                    
                } else {
                    NSLog(@"comicStore: comic not active: %@", object[@"comicName"]);
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"comicStore: error: %@ %@", error, [error userInfo]);
        }
        
        // Send NSNotification to comix view
        // to say that data fetch is done
        NSString *notificationName = @"KJComicDataFetchDidHappen";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        
        // Set firstLoad = YES in NSUserDefaults
        //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"comicLoadDone"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

@end
