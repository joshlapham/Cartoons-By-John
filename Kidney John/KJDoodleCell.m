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
        // Initialization code
        self.doodleImageView = [[UIImageView alloc] init];
        self.doodleImageView.frame = self.bounds;
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
