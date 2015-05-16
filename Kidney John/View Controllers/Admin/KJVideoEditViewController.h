//
//  KJVideoEditViewController.h
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "QuickDialogController.h"
#import <Parse/Parse.h>

@interface KJVideoEditViewController : QuickDialogController

// Properties
@property (nonatomic, strong) PFObject *chosenVideo;

@end
