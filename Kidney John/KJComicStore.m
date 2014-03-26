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

#pragma mark - load initial comic data

- (void)loadInitialComicData
{
    // this method will load all comics into core data
    // if this is the first time the app has been run
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"appHasCompletedFirstLaunch"] != NO) {
        // app has already been launched, no need to load initial data
    } else {
        // app has never been launched, load initial comic data
        [self persistNewComicWithName:@"Aeroplane" comicFileData:nil comicFileName:@"aeroplane" comicFileUrl:nil];
        [self persistNewComicWithName:@"Army Men" comicFileData:nil comicFileName:@"armymen" comicFileUrl:nil];
        [self persistNewComicWithName:@"Are We There Yet?" comicFileData:nil comicFileName:@"arewethereyet" comicFileUrl:nil];
        
        // set NSUserDefaults to indicate that we have launched app
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appHasCompletedFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Comic files on filesystem methods

- (NSArray *)returnComicsFolderAsArray
{
    return [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"];
}

- (NSString *)returnFilepathForComicObject:(KJComic *)comicObject
{
    //NSString *fileNameToReturn = [[NSString alloc] init];
    
    //NSLog(@"type: %@", [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"] class]);
    
    // Documents folder path
//    dirArray = [NSArray array];
//    dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    filePath = [NSString stringWithFormat:@"%@/%@.png", [dirArray objectAtIndex:0], comicObject.comicFileName];
    
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Comics"];
    
    filePath = [NSString stringWithFormat:@"%@/%@.png", comicsFolderPath, comicObject.comicFileName];
    
    //NSLog(@"%@", filePath);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            NSLog(@"comic file exists!");
        } else {
            NSLog(@"comic file does not exist");
        }
    
//    // TODO: make this better
//    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"]) {
//        //NSLog(@"%@", fileName);
//        if ([fileName isEqualToString:comicObject.comicFileName]) {
//            fileNameToReturn = fileName;
//        } else {
//            fileNameToReturn = nil;
//        }
//    }
//    
//    NSLog(@"%@", fileNameToReturn);
    
    return filePath;
}

- (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject
{
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnFilepathForComicObject:comicObject]];
    
//    // TODO: make this better
//    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"]) {
//        //NSLog(@"%@", fileName);
//        if ([fileName isEqualToString:comicObject.comicFileName]) {
//            imageToReturn = [[UIImage alloc] initWithContentsOfFile:comicObject.comicFileName];
//        } else {
//            return nil;
//        }
//    }
    
    NSLog(@"image: %@", imageToReturn);
    
    return imageToReturn;
}

- (NSArray *)returnArrayOfComicFiles
{
    // load from resources path
    NSMutableArray *comicFileResults = [[NSMutableArray alloc] init];
    
    //NSBundle *comicBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Comics" ofType:@"png"]];
    //NSLog(@"bundle: %@", comicBundle);
    NSUInteger pngCount = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"] count];
    NSLog(@"bundle count: %d", pngCount);
    
    for (NSString *fileName in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"Comics"]) {
        //NSLog(@"%@", fileName);
        [comicFileResults addObject:fileName];
    }
    
    return [NSArray arrayWithArray:comicFileResults];
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

#pragma mark - return comic with comic name method

- (KJComic *)returnComicWithComicName:(NSString *)comicNameToFind
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
{
    NSLog(@"in comic store save with block method ..");
    
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
        
        // Set comic file data from comicData string
        // DISABLED as we are using SDWebImage for comic image caching
//            NSURL *comicDataUrl = [NSURL URLWithString:comicData];
//            newComic.comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
        
        // DEBUGGING
        NSLog(@"CORE DATA: %@", newComic);
        
        // Save
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"saved successfully");
                
                // Send NSNotification to comix view
                // to say that data fetch is done
                NSString *notificationName = @"KJComicDataFetchDidHappen";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            } else {
                NSLog(@"Error saving %@: %@", newComic.comicFileName, error);
            }
        }];
    // if comic already exists in database, then send notification
    } else {
        // Send NSNotification to comix view
        // to say that data fetch is done
        NSString *notificationName = @"KJComicDataFetchDidHappen";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    }
}

- (void)fetchComicData
{
//    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(defaultQueue, ^{
//        NSLog(@"COMIX: in GCD default queue thread ..");
    
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
                        
                        [self persistNewComicWithName:object[@"comicName"] comicFileData:nil comicFileName:object[@"comicFileName"] comicFileUrl:comicImageFile.url];
                        
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
                        NSLog(@"COMIX: comic not active: %@", object[@"comicName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"comicLoadDone"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
        }];
    //});
}

@end
