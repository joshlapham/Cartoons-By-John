//
//  KJVideoEditViewController.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoEditViewController.h"
#import <QRootElement.h>
#import <QSection.h>
#import <QLabelElement.h>
#import <QEntryElement.h>
#import <QBooleanElement.h>

@interface KJVideoEditViewController ()

@end

@implementation KJVideoEditViewController

#pragma mark - dealloc method

- (void)dealloc {
}

#pragma mark - Init method

- (instancetype)init {
    self = [super init];
    if (self) {
        self.root = [self buildRoot];
        self.resizeWhenKeyboardPresented = YES;
    }
    
    return self;
}

#pragma mark - QuickDialog methods

#pragma mark Build root method

- (QRootElement *)buildRoot {
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    
    // Set title
    root.title = [self.chosenVideo valueForKey:@"videoName"];
    
    // Section
    {
        QSection *section = [[QSection alloc] init];
        
        // Video name
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Title";
            element.value = [self.chosenVideo valueForKey:@"videoName"];
            
            [section addElement:element];
        }
        
        // Video description
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Description";
            element.value = [self.chosenVideo valueForKey:@"videoDescription"];
            
            [section addElement:element];
        }
        
        // Add all to root
        [root addSection:section];
    }
    
    return root;
}

@end
