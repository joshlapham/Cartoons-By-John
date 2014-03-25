//
//  KJComicStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJComic.h"

@interface KJComicStore : NSObject

- (void)fetchComicData;
- (KJComic *)returnComicWithComicName:(NSString *)comicName;

@end
