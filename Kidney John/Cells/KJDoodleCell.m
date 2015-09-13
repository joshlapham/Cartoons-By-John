//
//  KJDoodleCell.m
//  Kidney John
//
//  Created by jl on 6/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleCell.h"
#import "KJRandomView.h"
#import "KJFavDoodlesListView.h"
#import "KJRandomImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KJDoodleCell ()

// Properties
@property (nonatomic, strong) UIImageView *doodleImageView;

@end

@implementation KJDoodleCell

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Init image view
        _doodleImageView = [[UIImageView alloc] init];
        
        // Scale image to fit
        _doodleImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Set frame to entire screen
        _doodleImageView.frame = self.bounds;
        
        // Add image view to cell's view
        [self addSubview:_doodleImageView];
    }
    
    return self;
}

#pragma mark - Configure cell with data method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJRandomImage *cellData = (KJRandomImage *)data;
    
    // TODO: review image setting here; use cache?
    
    // SDWebImage
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl]) {
        _doodleImageView.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cellData.imageUrl];
    }
    
    // TODO: fallback if no image in cache
    else {
        //DDLogVerbose(@"no image in cache");
    }
    
    // Set doodle image
    [_doodleImageView sd_setImageWithURL:[NSURL URLWithString:cellData.imageUrl]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                               completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                   if (cellImage && !error) {
                                       DDLogVerbose(@"Doodles: fetched image from URL: %@", url);
                                   } else {
                                       DDLogError(@"Doodles: error fetching image: %@\nURL: %@\nID: %@", error.debugDescription, url, cellData.imageId);
                                   }
                               }];
}

#pragma mark - Accessibility methods

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityHint {
    // Determine which VC presented this cell and return appropriate string
    // VC tags
    NSInteger doodlesViewControllerTag = 1001;
    NSInteger doodlesFavListViewControllerTag = 1002;
    
    // Doodles VC
    if (self.superview.tag == doodlesViewControllerTag) {
        return NSLocalizedString(@"Swipe left or right to navigate between images", nil);
    }
    
    // Doodles Favourite List VC
    if (self.superview.tag == doodlesFavListViewControllerTag) {
        return NSLocalizedString(@"Tap to view image", nil);
    }
    
    // NOTE - returning nil by default
    return nil;
}

@end
