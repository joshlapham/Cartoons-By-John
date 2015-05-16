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
#import <QDateTimeElement.h>
#import <QDateTimeInlineElement.h>

@interface KJVideoEditViewController ()

// Properties
@property (nonatomic) BOOL userDidMakeEdits;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

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
    
    // Init 'Save' navbar button
    _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                target:self
                                                                action:@selector(didTapSaveButton:)];
    // NOTE - disabled at the start
    _saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _saveButton;
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
        section.title = @"Details";
        
        // Video ID
        NSString *videoId = [self.chosenVideo valueForKey:@"videoId"];
        if (videoId) {
            {
                QLabelElement *element = [[QLabelElement alloc] init];
                element.title = @"ID";
                element.value = videoId;
                
                [section addElement:element];
            }
        }
        
        // Video name
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Title";
            element.textValue = [self.chosenVideo valueForKey:@"videoName"];
            
            element.onValueChanged = ^(QRootElement *rootElement) {
                //                __weak typeof(element) weakElement;
                
                [self setUserDidMakeEdits:YES];
                
                //                if (weakElement.value) {
                //                }
            };
            
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
        
        // Video date
        {
            QDateTimeInlineElement *element = [[QDateTimeInlineElement alloc] init];
            element.title = @"Date";
            element.dateValue = [NSDate date];
            element.mode = UIDatePickerModeDate;
            //            element.showPickerInCell = YES;
            
            // TODO: set date value (parse date string)
            //            element.textValue = [self.chosenVideo valueForKey:@"date"];
            
            [section addElement:element];
        }
        
        // Add section to root
        [root addSection:section];
    }
    
    // Section
    {
        QSection *section = [[QSection alloc] init];
        section.footer = @"Determine if this item will appear in the app.";
        
        // Video is active?
        {
            QBooleanElement *element = [[QBooleanElement alloc] init];
            element.title = @"Is Active?";
            element.boolValue = [[self.chosenVideo valueForKey:@"is_active"] isEqualToString:@"1"] ? YES : NO;
            
            [section addElement:element];
        }
        
        // Add section to root
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

- (IBAction)didTapSaveButton:(id)sender {
    // Init strings for alert
    // NOTE - these aren't localized strings as end-users will (hopefully) never see this view controller
    NSString *alertTitle = @"Are You Sure?";
    NSString *alertMessage = @"Are you sure you want to save changes made to this item?";
    NSString *yesButtonTitle = @"Yes";
    
    // Init alertView
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                          message:alertMessage
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions
    // Yes
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesButtonTitle
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          // TODO: implement this
                                                          // Go back to previous view
                                                          //                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }];
    
    // Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [confirmAlert addAction:yesAction];
    [confirmAlert addAction:cancelAction];
    
    // Show alertView
    [self presentViewController:confirmAlert
                       animated:YES
                     completion:nil];
}

#pragma mark - Getter/setter overrides

- (void)setChosenVideo:(PFObject *)chosenVideo {
    _chosenVideo = chosenVideo;
    
    // Re-build QuickDialog root element
    self.root = [self buildRoot];
}

- (void)setUserDidMakeEdits:(BOOL)userDidMakeEdits {
    _userDidMakeEdits = userDidMakeEdits;
    
    // Enable 'Save' button
    if (_userDidMakeEdits == YES) {
        _saveButton.enabled = YES;
    }
    
    // Disable 'Save' button
    else {
        _saveButton.enabled = NO;
    }
}

@end
