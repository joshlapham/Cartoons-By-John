//
//  KJComicCell.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicCell.h"
#import "KJComic.h"
#import "KJComic+Methods.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KJComicCell ()

// Properties
@property (nonatomic, strong) NSString *comicTitle;
@property (strong, nonatomic) UIImageView *comicImageView;

@end

@implementation KJComicCell

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Init imageView
        _comicImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        // Make comic scale to fill view
        _comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to view
        [self addSubview:_comicImageView];
    }
    
    return self;
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJComic *cellData = (KJComic *)data;
    
    // Set comic title
    _comicTitle = cellData.comicName;
    
    // Set comic thumbnail using SDWebImage
    [_comicImageView sd_setImageWithURL:[NSURL fileURLWithPath:[cellData returnThumbnailFilepathForComic]]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                              completed:^(UIImage *cellImage, NSError *error,
                                          SDImageCacheType cacheType,
                                          NSURL *url) {
                                  if (cellImage && !error) {
                                      DDLogVerbose(@"Comix: fetched comic thumbnail image from URL: %@", url);
                                  }
                                  
                                  // TODO: implement fallback
                                  else {
                                      DDLogError(@"Comix: error fetching comic thumbnail image: %@", [error localizedDescription]);
                                  }
                              }];
}

#pragma mark - Accessibility methods

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *accessibilityString = [NSString stringWithFormat:@"Comic title: %@",
                                     _comicTitle];
    
    return NSLocalizedString(accessibilityString, nil);
}

- (NSString *)accessibilityHint {
    return NSLocalizedString(@"Tap to view comic", nil);
}

@end
