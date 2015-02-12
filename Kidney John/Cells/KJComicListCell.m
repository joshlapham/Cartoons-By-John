//
//  KJComicListCell.m
//  Kidney John
//
//  Created by Josh Lapham on 12/02/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJComicListCell.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"

@implementation KJComicListCell

#pragma mark - Awake from NIB method

- (void)awakeFromNib {
    // Comic name
    self.comicTitle.font = [UIFont kj_videoNameFont];
    self.comicTitle.numberOfLines = 0;
    self.comicTitle.preferredMaxLayoutWidth = 130;
    
    // Comic thumbnail
    self.comicThumbnail.contentMode = UIViewContentModeScaleAspectFit;
    
    // New! label
    self.comicIsNew.font = [UIFont kj_videoNewLabelFont];
    self.comicIsNew.textColor = [UIColor whiteColor];
    self.comicIsNew.backgroundColor = [UIColor kj_newVideoLabelColour];
    self.comicIsNew.numberOfLines = 0;
    self.comicIsNew.textAlignment = NSTextAlignmentCenter;
    
    // Make label round
    self.comicIsNew.layer.masksToBounds = YES;
    self.comicIsNew.layer.cornerRadius = self.comicIsNew.frame.size.width / 2;
    
    // Init text
    NSString *labelText = NSLocalizedString(@"New!", @"Text for label that highlights if a comic is new");
    self.comicIsNew.text = labelText;
}

#pragma mark - Prepare for reuse method

- (void)prepareForReuse {
    // Set videoIsNew label to hidden, so label won't show every few cells as tableView is scrolled.
    // NOTE - we toggle hidden property in tableView configureCell method.
    self.comicIsNew.hidden = YES;
}

#pragma mark - Cell reuse identifer method

+ (NSString *)cellIdentifier {
    return [NSString stringWithFormat:@"%@", self.class];
}

@end
