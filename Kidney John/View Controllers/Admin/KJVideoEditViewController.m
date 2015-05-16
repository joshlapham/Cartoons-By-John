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
        self.resizeWhenKeyboardPresented = YES;
    }
    
    return self;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init 'Cancel' navbar button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(didTapCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
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
            element.textValue = [self.chosenVideo valueForKey:@"videoName"];
            
            [section addElement:element];
        }
        
        // Video description
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Description";
            element.textValue = [self.chosenVideo valueForKey:@"videoDescription"];
            
            [section addElement:element];
        }
        
        // Video duration
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Duration";
            element.textValue = [self.chosenVideo valueForKey:@"videoDuration"];
            
            [section addElement:element];
        }
        
        // Video is active?
        {
            QBooleanElement *element = [[QBooleanElement alloc] init];
            element.title = @"Is Active?";
            element.boolValue = [[self.chosenVideo valueForKey:@"is_active"] isEqualToString:@"1"] ? YES : NO;
            
            [section addElement:element];
        }
        
        // Add all to root
        [root addSection:section];
    }
    
    return root;
}

#pragma mark - Action handler methods

- (IBAction)didTapCancelButton:(id)sender {
    // Go back to previous view controller
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Getter/setter overrides

- (void)setChosenVideo:(PFObject *)chosenVideo {
    _chosenVideo = chosenVideo;
    
    // Re-build QuickDialog root element
    self.root = [self buildRoot];
}

@end
