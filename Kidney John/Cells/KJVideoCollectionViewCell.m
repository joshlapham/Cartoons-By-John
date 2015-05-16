//
//  KJVideoCollectionViewCell.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoCollectionViewCell.h"
#import "KJVideo.h"

@interface KJVideoCollectionViewCell ()

// Properties
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation KJVideoCollectionViewCell

#pragma mark - Awake from NIB (init) method

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // TODO: implement
    
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 100, 50)];
    [self addSubview:_descriptionLabel];
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJVideo *cellData = (KJVideo *)data;
    
    // TODO: implement
    
    _descriptionLabel.text = cellData.videoName;
}

@end
