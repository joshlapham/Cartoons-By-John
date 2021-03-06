//
//  KJVideoCollectionViewCell.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoCollectionViewCell.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "KJVideo+Methods.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJVideoStore.h"

@interface KJVideoCollectionViewCell ()

// Properties
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@end

@implementation KJVideoCollectionViewCell

//#pragma mark - Awake from NIB (init) method
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//    NSLog(@"%@ - %s", [self class], __func__);
//
//    // TODO: implement
//
//    self.contentView.backgroundColor = [UIColor whiteColor];
//
//    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 100, 50)];
//    [_descriptionLabel setTextColor:[UIColor blackColor]];
//    [self.contentView addSubview:_descriptionLabel];
//}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    
    // TODO: fix all this
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // Style label text
    [_nameLabel setTextColor:[UIColor blackColor]];
    [_descriptionLabel setTextColor:[UIColor blackColor]];
    [_durationLabel setTextColor:[UIColor kj_videoDurationTextColour]];
    _nameLabel.font = [UIFont kj_videoNameFont];
    _descriptionLabel.font = [UIFont kj_videoDescriptionFont];
    _durationLabel.font = [UIFont kj_videoDurationFont];
    
    // Init cell data
    PFObject *cellData = (PFObject *)data;
    
    // TODO: implement
    _nameLabel.text = [cellData valueForKey:KJParseKeyVideosName];
    // NOTE - description label is actually date
    _descriptionLabel.text = [cellData valueForKey:KJParseKeyVideosDate];
    _durationLabel.text = [cellData valueForKey:KJParseKeyVideosDuration];
    
    NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString, [cellData valueForKey:KJParseKeyVideosId]];
    
    [_thumbnailView sd_setImageWithURL:[NSURL URLWithString:urlString]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                             completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                 if (cellImage && !error) {
                                     DDLogVerbose(@"%s: fetched video thumbnail image from URL: %@", __func__, url);
                                 } else {
                                     DDLogError(@"%s: error fetching video thumbnail image: %@", __func__, [error localizedDescription]);
                                 }
                             }];
}

@end
