//
//  KJSocialLinkStore.m
//  Kidney John
//
//  Created by jl on 15/11/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJSocialLinkStore.h"
#import <Parse/Parse.h>
#import "KJSocialLink.h"

// Constant for NSNotification name
NSString * const KJSocialLinkDataFetchDidHappenNotification = @"KJSocialLinkDataFetchDidHappen";

@implementation KJSocialLinkStore

#pragma mark - Init method

+ (KJSocialLinkStore *)sharedStore
{
    static KJSocialLinkStore *_sharedStore = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJSocialLinkStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Core Data methods

+ (BOOL)hasInitialDataFetchHappened
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstSocialLinksFetchDone"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkIfSocialLinkIsInDatabaseWithUrl:(NSString *)urlToCheck context:(NSManagedObjectContext *)context
{
    if ([KJSocialLink MR_findFirstByAttribute:@"url" withValue:urlToCheck inContext:context]) {
        //DDLogVerbose(@"socialLinkStore: Yes, social link does exist in database");
        return TRUE;
    } else {
        //DDLogVerbose(@"socialLinkStore: No, social link does NOT exist in database");
        return FALSE;
    }
}

+ (void)persistNewSocialLinkWithTitle:(NSString *)titleValue
                                  url:(NSString *)urlValue
                             imageUrl:(NSString *)imageUrlValue
                            imagePath:(NSString *)imagePathValue
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If Social Link does not exist in database then persist
    if (![self checkIfSocialLinkIsInDatabaseWithUrl:urlValue context:localContext]) {
        // Create a new Social Link in the current context
        KJSocialLink *newSocialLink = [KJSocialLink MR_createInContext:localContext];
        
        // Set attributes
        newSocialLink.title = titleValue;
        newSocialLink.url = urlValue;
        newSocialLink.imageUrl = imageUrlValue;
        newSocialLink.imagePath = imagePathValue;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

+ (void)checkIfSocialLinkNeedsUpdateWithTitle:(NSString *)titleValue
                                          url:(NSString *)urlValue
                                     imageUrl:(NSString *)imageUrlValue
                                    imagePath:(NSString *)imagePathValue
{
    // TODO: this keeps returning TRUE
    
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If link is in database ..
    if ([self checkIfSocialLinkIsInDatabaseWithUrl:urlValue context:localContext]) {
        KJSocialLink *linkToCheck = [KJSocialLink MR_findFirstByAttribute:@"url" withValue:urlValue inContext:localContext];
        
        // Check if linkToCheck needs updating
        if (![linkToCheck.title isEqualToString:titleValue] || ![linkToCheck.url isEqualToString:urlValue] || ![linkToCheck.imageUrl isEqualToString:imageUrlValue] || ![linkToCheck.imagePath isEqualToString:imagePathValue]) {
            // Link needs updating
            DDLogVerbose(@"socialLinkStore: social link needs update: %@", linkToCheck.title);
            
            linkToCheck.title = titleValue;
            linkToCheck.url = urlValue;
            linkToCheck.imageUrl = imageUrlValue;
            linkToCheck.imagePath = imagePathValue;
            
            // Save
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    DDLogVerbose(@"socialLinkStore: updated link: %@", linkToCheck.title);
                } else if (error) {
                    DDLogVerbose(@"socialLinkStore: error updating link: %@ - %@", linkToCheck.title, [error localizedDescription]);
                }
            }];
        }
    }
}

#pragma mark - Fetch data method

+ (void)fetchSocialLinkData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"socialLinkStore: fetching social link data ..");
        
        // Setup query
        PFQuery *query = [PFQuery queryWithClassName:@"SocialLink"];
        
        // Query all social link URLs
        [query whereKey:@"title" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                // Loop over found objects
                for (PFObject *object in objects) {
                    // Check if social link is active or not
                    if ([object[@"is_active"] isEqual:@1]) {
                        DDLogVerbose(@"socialLinkStore: link IS active: %@", object[@"title"]);
                        
                        // Init PFFile so we can get the URL to the image file itself on Parse
                        PFFile *imageFile = object[@"image"];
                        
                        // Check if link needs updating
                        // TODO: this keeps returning TRUE
                        [self checkIfSocialLinkNeedsUpdateWithTitle:object[@"title"] url:object[@"url"] imageUrl:imageFile.url imagePath:object[@"imagePath"]];
                        
                        // Save Parse object to Core Data
                        [self persistNewSocialLinkWithTitle:object[@"title"] url:object[@"url"] imageUrl:imageFile.url imagePath:object[@"imagePath"]];
                        
                    } else {
                        DDLogVerbose(@"socialLinkStore: link not active: %@", object[@"title"]);
                    }
                }
                // Set firstSocialLinksFetchDone = YES in NSUserDefaults
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstSocialLinksFetchDone"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Send NSNotification to say that data fetch is done
                [[NSNotificationCenter defaultCenter] postNotificationName:KJSocialLinkDataFetchDidHappenNotification
                                                                    object:nil];
                
            } else {
                // Log details of the failure
                DDLogVerbose(@"socialLinkStore: error: %@ %@", error, [error userInfo]);
            }
        }];
    });
}

@end