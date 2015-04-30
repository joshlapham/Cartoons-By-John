//
//  KJAppDelegate.h
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KJAppDelegate : UIResponder <UIApplicationDelegate>

// Properties
@property (strong, nonatomic) UIWindow *window;

// Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Methods
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
