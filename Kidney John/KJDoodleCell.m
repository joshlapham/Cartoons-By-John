//
//  KJDoodleCell.m
//  Kidney John
//
//  Created by jl on 6/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleCell.h"

@implementation KJDoodleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Init image view
        self.doodleImageView = [[UIImageView alloc] init];
        // scale image to fit
        [self.doodleImageView setContentMode:UIViewContentModeScaleAspectFit];
        // set frame to entire screen
        self.doodleImageView.frame = self.bounds;
        // add image view to cell's view
        [self addSubview:self.doodleImageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
