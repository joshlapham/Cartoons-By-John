//
//  KJRandomViewDataSource.h
//  Kidney John
//
//  Created by jl on 14/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJRandomViewDataSource : NSObject <UICollectionViewDataSource>

// Properties
@property (nonatomic, strong) NSArray *cellDataSource;

@end
