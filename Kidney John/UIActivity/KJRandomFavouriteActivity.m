//
//  KJRandomFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 6/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJRandomFavouriteActivity.h"
#import "KJDoodleStore.h"
#import "KJRandomImage.h"

@implementation KJRandomFavouriteActivity {
    NSString *titleOfActivity;
    KJRandomImage *doodleObject;
}

#pragma mark - Init method

- (id)initWithDoodle:(KJRandomImage *)doodle {
    self = [super init];
    if (self) {
        // Init doodle object
        doodleObject = doodle;
        
        // Init activity title, depending on favourite status of doodle
        if (!doodleObject.isFavourite) {
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
    return @"com.joshlapham.Kidney-John favourite doodle";
}

- (NSString *)activityTitle {
    return titleOfActivity;
}

- (UIImage *)activityImage {
    if (!doodleObject.isFavourite) {
        return [UIImage imageNamed:@"add-to-fav.png"];
    }
    else {
        return [UIImage imageNamed:@"remove-from-fav.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Toggle favourite status for doodleObject
    doodleObject.isFavourite = !doodleObject.isFavourite;
    
    // Save
    [doodleObject.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (!error && success) {
            DDLogVerbose(@"%@ - successfully updated favourite status for doodle %@", self.class, doodleObject.imageUrl);
        }
        else {
            DDLogError(@"%@ - error updating favourite status for doodle %@: %@", self.class, doodleObject.imageUrl, [error localizedDescription]);
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
