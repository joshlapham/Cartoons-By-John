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
#import "KJComic.h"
#import "KJComic+Methods.h"

@interface KJComicListCell ()

// Properties
@property (nonatomic, strong) NSString *comicName;
@property (weak, nonatomic) IBOutlet UILabel *comicTitle;
@property (weak, nonatomic) IBOutlet UIImageView *comicThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *comicIsNew;

@end

@implementation KJComicListCell

#pragma mark - Awake from NIB method

- (void)awakeFromNib {
    // Comic name
    _comicTitle.font = [UIFont kj_videoNameFont];
    _comicTitle.numberOfLines = 0;
    _comicTitle.preferredMaxLayoutWidth = 130;
    
    // Comic thumbnail
    _comicThumbnail.contentMode = UIViewContentModeScaleAspectFit;
    
    // New! label
    _comicIsNew.font = [UIFont kj_videoNewLabelFont];
    _comicIsNew.textColor = [UIColor whiteColor];
    _comicIsNew.backgroundColor = [UIColor kj_newVideoLabelColour];
    _comicIsNew.numberOfLines = 0;
    _comicIsNew.textAlignment = NSTextAlignmentCenter;
    
    // Make label round
    _comicIsNew.layer.masksToBounds = YES;
    _comicIsNew.layer.cornerRadius = _comicIsNew.frame.size.width / 2;
    
    // Init text
    NSString *labelText = NSLocalizedString(@"New!", @"Text for label that highlights if a comic is new");
    _comicIsNew.text = labelText;
}

#pragma mark - Prepare for reuse method

- (void)prepareForReuse {
    // Set videoIsNew label to hidden, so label won't show every few cells as tableView is scrolled.
    // NOTE - we toggle hidden property in tableView configureCell method.
    _comicIsNew.hidden = YES;
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init data
    KJComic *cellData = (KJComic *)data;
    
    // Set comic title
    _comicName = cellData.comicName;
    
    // Set cell label text
    _comicTitle.text = cellData.comicName;
    _comicThumbnail.image = [cellData returnComicThumbImageFromComic];
}

#pragma mark - Accessibility methods

- (NSString *)accessibilityLabel {
    NSString *accessibilityString = [NSString stringWithFormat:@"Comic title: %@",
                                     _comicName];
    
    return NSLocalizedString(accessibilityString, nil);
}

- (NSString *)accessibilityHint {
    return NSLocalizedString(@"Tap to view comic", nil);
}

@end
