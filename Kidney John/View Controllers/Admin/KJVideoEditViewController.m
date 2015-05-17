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
#import <MBProgressHUD.h>
#import <QButtonElement.h>
#import <QAppearance.h>
#import <QElement+Appearance.h>

@interface KJVideoEditViewController ()

// Properties
@property (nonatomic) BOOL userDidMakeEdits;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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

#pragma mark - Lazy init date formatter method

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter != nil) {
        return _dateFormatter;
    }
    
    // Init date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    _dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    return _dateFormatter;
}

#pragma mark - QuickDialog methods

#pragma mark Appearance

- (QAppearance *)appearanceForDeleteButton {
    QAppearance *appearance = [[QAppearance alloc] init];
    appearance.actionColorEnabled = [UIColor redColor];
    appearance.backgroundColorEnabled = [UIColor whiteColor];
    
    return appearance;
}

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
                [self setUserDidMakeEdits:YES];
                
                // TODO: fix compiler warning here
                
                //                __weak typeof(element) weakElement;
                
                [self.chosenVideo setValue:element.textValue
                                    forKey:@"videoName"];
            };
            
            [section addElement:element];
        }
        
        // Video description
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Description";
            element.textValue = [self.chosenVideo valueForKey:@"videoDescription"];
            
            element.onValueChanged = ^(QRootElement *rootElement) {
                [self setUserDidMakeEdits:YES];
                
                // TODO: fix compiler warning here
                
                //                __weak typeof(element) weakElement;
                
                [self.chosenVideo setValue:element.textValue
                                    forKey:@"videoDescription"];
            };
            
            [section addElement:element];
        }
        
        // Video duration
        {
            QEntryElement *element = [[QEntryElement alloc] init];
            element.title = @"Duration";
            element.textValue = [self.chosenVideo valueForKey:@"videoDuration"];
            
            element.onValueChanged = ^(QRootElement *rootElement) {
                [self setUserDidMakeEdits:YES];
                
                // TODO: fix compiler warning here
                
                //                __weak typeof(element) weakElement;
                
                [self.chosenVideo setValue:element.textValue
                                    forKey:@"videoDuration"];
            };
            
            [section addElement:element];
        }
        
        // Video date
        {
            QDateTimeInlineElement *element = [[QDateTimeInlineElement alloc] init];
            element.title = @"Date";
            element.mode = UIDatePickerModeDate;
            //            element.showPickerInCell = YES;
            
            // Set date value (parse date string)
            NSString *dateString = [self.chosenVideo valueForKey:@"date"];
            NSDate *videoDate = [[self dateFormatter] dateFromString:dateString];
            
            element.dateValue = videoDate;
            element.textValue = dateString;
            
            element.onValueChanged = ^(QRootElement *rootElement) {
                [self setUserDidMakeEdits:YES];
                
                // TODO: fix compiler warning here
                
                //                NSLog(@"ELEMENT VALUE : %@", element.value);
                NSLog(@"%s - CHOSEN DATE : %@", __func__, [[self dateFormatter] stringFromDate:element.dateValue]);
                
                [self.chosenVideo setValue:[[self dateFormatter] stringFromDate:element.dateValue]
                                    forKey:@"date"];
            };
            
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
            
            id existingValue = [self.chosenVideo valueForKey:@"is_active"];
            BOOL valueToSet = NO;
            
            // TODO: fix this hackiness
            
            if ([existingValue respondsToSelector:@selector(isEqualToString:)]) {
                if ([existingValue isEqualToString:@"1"]) {
                    valueToSet = YES;
                }
                
                else {
                    valueToSet = NO;
                }
            }
            
            else {
                valueToSet = NO;
            }
            
            element.boolValue = valueToSet;
            
            element.onValueChanged = ^(QRootElement *rootElement) {
                [self setUserDidMakeEdits:YES];
                
                //                __weak typeof(element) weakElement;
                
                // TODO: fix weak compiler warning here
                
                //                NSString *boolString = weakElement.boolValue ? @"1" : @"0";
                NSString *boolString = element.boolValue ? @"1" : @"0";
                
                
                //                NSLog(@"NON WEAK BOOL VALUE : %hhd", element.boolValue);
                //                NSLog(@"BOOL VALUE : %hhd", weakElement.boolValue);
                //                NSLog(@"BOOL STRING : %@", boolString);
                
                if ([boolString isEqualToString:@"0"]) {
                    [self.chosenVideo setValue:[NSNull null]
                                        forKey:@"is_active"];
                }
                
                else {
                    [self.chosenVideo setValue:boolString
                                        forKey:@"is_active"];
                }
                
            };
            
            [section addElement:element];
        }
        
        // Add section to root
        [root addSection:section];
    }
    
    // Section
    {
        QSection *section = [[QSection alloc] init];
        section.footer = @"Delete this item from the app & server.";
        
        // Delete video
        {
            QButtonElement *element = [[QButtonElement alloc] init];
            element.title = @"Delete";
            element.controllerAction = @"didTapDeleteButton:";
            element.appearance = [self appearanceForDeleteButton];
            
            [section addElement:element];
        }
        
        // Add section to root
        [root addSection:section];
    }
    
    return root;
}

#pragma mark - Action handler methods

- (IBAction)didTapDeleteButton:(id)sender {
    NSLog(@"%s", __func__);
    
    // TODO: Init confirm alert
}

- (IBAction)didTapCancelButton:(id)sender {
    // Show confirm alert if changes made
    if (_userDidMakeEdits) {
        // Init alert
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Are You Sure?"
                                                                              message:@"Are you sure you want to discard changes made to this item?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        // Init actions
        // Yes
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
                                                              // Go back to previous view
                                                              [self dismissViewControllerAnimated:YES
                                                                                       completion:nil];
                                                          }];
        
        // Cancel
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [confirmAlert addAction:yesAction];
        [confirmAlert addAction:cancelAction];
        
        // Show alert
        [self presentViewController:confirmAlert
                           animated:YES
                         completion:nil];
    }
    
    // No changes made
    else {
        // Go back to previous view controller
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
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
                                                          // Confirm and save to Parse
                                                          [self userDidConfirmSave:self];
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

- (IBAction)userDidConfirmSave:(id)sender {
    DDLogInfo(@"%s - updating item %@ on Parse", __func__, [self.chosenVideo valueForKey:@"videoName"]);
    
    // Show progress
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    // Save to Parse
    [self.chosenVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Hide progress
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];
        
        if (!error) {
            // Go back to previous view
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        }
        
        // Handle error
        else {
            // Init alert
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                message:@"An error occured. Please try again."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            
            // Init actions
            UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:nil];
            
            [errorAlert addAction:okayAction];
            
            // Show alert
            [self presentViewController:errorAlert
                               animated:YES
                             completion:nil];
        }
    }];
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
