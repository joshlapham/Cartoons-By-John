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

@end

@implementation KJVideoCollectionViewCell

#pragma mark - Awake from NIB (init) method

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // TODO: implement
}

#pragma mark - Configure cell method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJVideo *cellData = (KJVideo *)data;
    
    // TODO: implement
}

@end
