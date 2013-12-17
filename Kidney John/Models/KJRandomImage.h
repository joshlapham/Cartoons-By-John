//
//  KJRandomImage.h
//  Kidney John
//
//  Created by jl on 18/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KJRandomImage : NSManagedObject

@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * imageDescription;
@property (nonatomic, retain) NSString * imageDate;
@property (nonatomic, retain) NSData * imageData;

@end
