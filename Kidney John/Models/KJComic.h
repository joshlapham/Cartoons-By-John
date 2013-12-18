//
//  KJComic.h
//  Kidney John
//
//  Created by jl on 18/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KJComic : NSManagedObject

@property (nonatomic, retain) NSString * comicName;
@property (nonatomic, retain) NSString * comicData;
@property (nonatomic, retain) NSData * comicThumbData;
@property (nonatomic, retain) NSString * comicFileName;

@end
