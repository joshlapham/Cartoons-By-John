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

@implementation KJComicStore

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
                      comicData:(NSString *)comicData
                 comicThumbData:(NSData *)comicThumbData
                  comicFileName:(NSString *)comicFileName
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSLog(@"in comic store save with block method ..");
        
        // Get the local context
        //localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        
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
            // DISABLED as we are using SDWebImage for comic image caching
//            NSURL *comicDataUrl = [NSURL URLWithString:comicData];
//            newComic.comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
            
            // DEBUGGING
            //NSLog(@"CORE DATA: %@", newComic.comicData);
            
            // Save
            [localContext MR_saveToPersistentStoreAndWait];
        }
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"in comic store completion block");
        
        // Send NSNotification to comix view
        // to say that data fetch is done
        NSString *notificationName = @"KJComicDataFetchDidHappen";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
    }];
}

- (void)fetchComicData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"COMIX: in GCD default queue thread ..");
        
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
                        // Save Parse object to Core Data
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
                        }];
                        
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
    });
}

@end
