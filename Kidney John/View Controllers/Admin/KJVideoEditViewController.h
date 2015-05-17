//
//  KJVideoEditViewController.h
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "QuickDialogController.h"
#import <Parse/Parse.h>

// ENUM for item type: either an existing item or we're creating a new one
typedef NS_ENUM(NSUInteger, KJVideoEditItemType) {
    KJVideoEditItemTypeExisting,
    KJVideoEditItemTypeNew,
};

@interface KJVideoEditViewController : QuickDialogController

// Properties
@property (nonatomic, strong) PFObject *chosenVideo;
@property (nonatomic) KJVideoEditItemType itemTypeForView;

// Methods

// Init
- (instancetype)initWithItemType:(KJVideoEditItemType)itemType;

@end
