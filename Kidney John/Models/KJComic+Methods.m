//
//  KJComic+Methods.m
//  Kidney John
//
//  Created by jl on 10/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJComic+Methods.h"

// Constants for comic filepaths
static NSString *kComicThumbnailFilepathFormat = @"%@/%@.jpg";
static NSString *kComicFilepathFormat = @"%@/%@%@.jpg";
static NSString *kComicsLocalDirectoryName = @"Comics";
static NSString *kComicThumbnailsLocalDirectoryName = @"ComicThumbs";

@implementation KJComic (Methods)

#pragma mark - Parse helper methods

+ (NSString *)parseClassName {
    return @"Comic";
}

#pragma mark - Return comic image methods

#pragma mark Comic thumbnails

- (UIImage *)returnComicThumbImageFromComic {
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnThumbnailFilepathForComic]];
    
    return imageToReturn;
}

#pragma mark Comics (full size)

// Method to return a comic image.
- (UIImage *)returnComicImageFromComic {
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self p_returnFilepathForComic]];
    
    return imageToReturn;
}

#pragma mark - Filepath for comics methods

// TODO: handle if filepath is nil

- (NSString *)returnThumbnailFilepathForComic {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicThumbnailsLocalDirectoryName];
    
    // Filepath for jpeg comic thumbs
    NSString *filePath = [NSString stringWithFormat:kComicThumbnailFilepathFormat,
                          comicsFolderPath,
                          self.comicNumber];
    
    return filePath;
}

#pragma mark - Private methods

// TODO: handle if filepath is nil

// Private method to return filepath for comic.
- (NSString *)p_returnFilepathForComic {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicsLocalDirectoryName];
    
    // Filepath for jpeg comics
    NSString *filePath;
    filePath = [NSString stringWithFormat:kComicFilepathFormat,
                comicsFolderPath,
                self.comicNumber,
                self.comicFileName];
    
    return filePath;
}

@end
