//
//  KJDoodleStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJDoodleStore : NSObject

- (void)fetchDoodleData;
- (NSArray *)getRandomImagesArray;

@end
