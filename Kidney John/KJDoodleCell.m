//
//  KJDoodleCell.m
//  Kidney John
//
//  Created by jl on 6/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleCell.h"

@implementation KJDoodleCell

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Init image view
        self.doodleImageView = [[UIImageView alloc] init];
        
        // Scale image to fit
        [self.doodleImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        // Set frame to entire screen
        self.doodleImageView.frame = self.bounds;
        
        // Add image view to cell's view
        [self addSubview:self.doodleImageView];
    }
    return self;
}

@end
