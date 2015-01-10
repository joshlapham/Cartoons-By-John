//
//  KJComicFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 6/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicFavouriteActivity.h"
#import "KJComicStore.h"
#import "KJComic.h"

@implementation KJComicFavouriteActivity {
    NSString *titleOfActivity;
    KJComic *comicObject;
}

#pragma mark - Init method

- (id)initWithComic:(KJComic *)comic {
    self = [super init];
    if (self) {
        // Init comic object
        comicObject = comic;
        
        // Init activity title, depending on favourite status of comic
        if (!comicObject.isFavourite) {
            titleOfActivity = NSLocalizedString(@"Add To Favourites", @"Title of button to favourite an item");
        }
        else {
            titleOfActivity = NSLocalizedString(@"Remove From Favourites", @"Title of button to remove an item as a favourite");
        }
    }
    
    return self;
}

#pragma mark - Other methods

- (NSString *)activityType {
    return @"com.joshlapham.Kidney-John favourite comic";
}

- (NSString *)activityTitle {
    return titleOfActivity;
}

- (UIImage *)activityImage {
    if (comicObject.isFavourite) {
        return [UIImage imageNamed:@"remove-from-fav.png"];
    }
    else {
        return [UIImage imageNamed:@"add-to-fav.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Toggle favourite status for comicObject
    comicObject.isFavourite = !comicObject.isFavourite;
    
    // Save
    [comicObject.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (!error && success) {
            DDLogVerbose(@"%@ - successfully updated favourite status for comic %@", self.class, comicObject.comicName);
        }
        else {
            DDLogError(@"%@ - error updating favourite status for comic %@: %@", self.class, comicObject.comicName, [error localizedDescription]);
        }
    }];
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
