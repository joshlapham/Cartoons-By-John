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

#pragma mark - Filepath for comics methods

#pragma mark Comic thumbnails

- (UIImage *)returnComicThumbImageFromComic {
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnThumbnailFilepathForComic]];
    
    //    DDLogVerbose(@"comicStore: thumb image: %@", imageToReturn);
    
    return imageToReturn;
}

// TODO: handle if filepath is nil

- (NSString *)returnThumbnailFilepathForComic {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicThumbnailsLocalDirectoryName];
    
    // Filepath for jpeg comic thumbs
    NSString *filePath = [NSString stringWithFormat:kComicThumbnailFilepathFormat,
                          comicsFolderPath,
                          self.comicNumber];
    
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
//    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic thumb file exists");
//    }
//    else {
        //DDLogVerbose(@"comicStore: comic thumb file does not exist");
//    }
    
    return filePath;
}

#pragma mark Comics (full size)

// Method to return a comic image.
- (UIImage *)returnComicImageFromComic {
    UIImage *imageToReturn = [[UIImage alloc] initWithContentsOfFile:[self returnFilepathForComic]];
    
    //    DDLogVerbose(@"comicStore: comic image: %@", imageToReturn);
    
    return imageToReturn;
}

// TODO: handle if filepath is nil

// Private method to return filepath for comic.
- (NSString *)returnFilepathForComic {
    NSString *comicsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kComicsLocalDirectoryName];
    
    // Filepath for jpeg comics
    NSString *filePath;
    filePath = [NSString stringWithFormat:kComicFilepathFormat,
                comicsFolderPath,
                self.comicNumber,
                self.comicFileName];
    
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    // TODO: make this better, return nil if none found
//    if (fileExists) {
        //DDLogVerbose(@"comicStore: comic file exists");
//    }
//    else {
        //DDLogVerbose(@"comicStore: comic file does not exist");
//    }

    return filePath;
}

@end
