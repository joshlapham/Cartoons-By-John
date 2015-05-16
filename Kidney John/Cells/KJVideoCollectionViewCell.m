//
//  KJVideoCollectionViewCell.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoCollectionViewCell.h"
#import <Parse/Parse.h>

@interface KJVideoCollectionViewCell ()

// Properties
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

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
    NSLog(@"%@ - %s", [self class], __func__);
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
//    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 100, 50)];
    [_nameLabel setTextColor:[UIColor blackColor]];
    [_descriptionLabel setTextColor:[UIColor blackColor]];
    [_durationLabel setTextColor:[UIColor blackColor]];
//    [self addSubview:_descriptionLabel];
    
    // Init cell data
    PFObject *cellData = (PFObject *)data;
    
    // TODO: implement
    _nameLabel.text = [cellData valueForKey:@"videoName"];
    _descriptionLabel.text = [cellData valueForKey:@"date"];
    _durationLabel.text = [cellData valueForKey:@"videoDuration"];
}

@end