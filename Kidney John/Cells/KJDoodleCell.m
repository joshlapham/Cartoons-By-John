//
//  KJDoodleCell.m
//  Kidney John
//
//  Created by jl on 6/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleCell.h"

@implementation KJDoodleCell

#pragma mark - Init method

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Init image view
        self.doodleImageView = [[UIImageView alloc] init];
        
        // Scale image to fit
        self.doodleImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Set frame to entire screen
        self.doodleImageView.frame = self.bounds;
        
        // Add image view to cell's view
        [self addSubview:self.doodleImageView];
    }
    
    return self;
}

#pragma mark - Accessibility methods

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityHint {
    return NSLocalizedString(@"Swipe left or right to navigate between images", nil);
}

@end
