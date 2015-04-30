//
//  KJComicCell.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicCell.h"
#import "KJComic.h"

@interface KJComicCell ()

// Properties
@property (nonatomic, strong) NSString *comicTitle;

@end

@implementation KJComicCell

@synthesize comicImageView;

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Init imageView
        comicImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        // Make comic scale to fill view
        comicImageView.contentMode = UIViewContentModeScaleToFill;
        
        // Add imageView to view
        [self addSubview:comicImageView];
    }
    
    return self;
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJComic *cellData = (KJComic *)data;
    
    // Set comic title
    _comicTitle = cellData.comicName;
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
