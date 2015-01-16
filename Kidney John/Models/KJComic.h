//
//  KJComic.h
//  Kidney John
//
//  Created by jl on 26/03/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KJComic : NSManagedObject

@property (nonatomic, retain) NSString * comicFileName;
@property (nonatomic, retain) NSString * comicName;
@property (nonatomic) BOOL isFavourite;
@property (nonatomic) BOOL isActive;
@property (nonatomic, retain) NSString * comicFileUrl;
@property (nonatomic, retain) NSString * comicNumber;

@end
