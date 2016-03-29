//
//  KJComic+Methods.h
//  Kidney John
//
//  Created by jl on 10/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJComic.h"

@interface KJComic (Methods)

// Filepath for comics methods
- (NSString *)returnThumbnailFilepathForComic;
- (UIImage *)returnComicThumbImageFromComic;
- (UIImage *)returnComicImageFromComic;

@end
