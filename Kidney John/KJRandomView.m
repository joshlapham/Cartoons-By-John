//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "MBProgressHUD.h"
#import "Models/KJRandomImage.h"
#import "KJDoodleStore.h"

@interface KJRandomView () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *randomImage;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@end

@implementation KJRandomView {
    __block NSArray *randomImagesResults;
    NSString *currentRandomImageUrl;
}

@synthesize randomImage, instructionLabel;

#pragma mark - NSNotification methods

- (void)doodleFetchDidHappen
{
    //NSLog(@"== doodle fetch did happen ==");
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Load a random image
    [self loadRandomImages];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"RANDOM: did dismiss instructions alert view, setting user defaults accordingly");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"doodleInstructionsShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Load Doodles method

- (void)loadRandomImages
{
    NSLog(@"RANDOM: in loadRandomImages method ...");
    randomImagesResults = [[NSArray alloc] init];
    randomImagesResults = [KJRandomImage MR_findAll];
    
    // Set the random image
    self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
    
    // Hide network activity monitor
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Display alert with instructions on how to use this screen on first load
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"doodleInstructionsShown"]) {
        NSLog(@"RANDOM: instructions have not yet been shown to user; now displaying");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Doodles"
                                                     message:@"Swipe left to load a new random doodle."
                                                    delegate:self
                                           cancelButtonTitle:Nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    } else {
        NSLog(@"RANDOM: instructions HAVE been shown to user");
    }
}

#pragma mark - Return random image from an array

- (UIImage *)getRandomImageFromArray:(NSArray *)arrayToCheck
{
    NSString *stringToReturn = [[NSString alloc] init];
    UIImage *imageToReturn;
    
    // Get random URL if it wasn't just displayed
    do {
        // TODO: check if array is empty, error if so
        NSUInteger randomIndex = arc4random() % [arrayToCheck count];
        //stringToReturn = [NSString stringWithFormat:@"%@", [arrayToCheck objectAtIndex:randomIndex]];
        KJRandomImage *returnedRandomImage = [arrayToCheck objectAtIndex:randomIndex];
        stringToReturn = returnedRandomImage.imageUrl;
        imageToReturn = [UIImage imageWithData:returnedRandomImage.imageData];
    } while ([stringToReturn isEqualToString:currentRandomImageUrl]);
    
    // Set last URL variable to the URL string we're using
    currentRandomImageUrl = stringToReturn;
    
    return imageToReturn;
}

#pragma mark - UISwipeGesture method

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"RANDOM: swipe received");
    if ([randomImagesResults count] != 0) {
        self.randomImage.image = [self getRandomImageFromArray:randomImagesResults];
    } else {
        NSLog(@"RANDOM: error - swipeHandler could not load an image due to an empty image URL array");
    }
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.title = @"Doodles";
    
    // Init navbar title label
    int height = self.navigationController.navigationBar.frame.size.height;
    int width = self.navigationController.navigationBar.frame.size.width;
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:24];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.text = @"Doodles";
    self.navigationItem.titleView = navLabel;
    
    // Instruction label init
    instructionLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:16];
    instructionLabel.textColor = [UIColor lightGrayColor];
    instructionLabel.text = @"Swipe To Load a Random Doodle";
    
    // Init swipe gesture recognizer for image view
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.randomImage addGestureRecognizer:self.gestureRecognizer];
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading doodles ...";
    
    // NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doodleFetchDidHappen) name:@"KJDoodleDataFetchDidHappen" object:nil];
    
    // Use the DoodleStore to fetch doodle data
    KJDoodleStore *store = [[KJDoodleStore alloc] init];
    [store fetchDoodleData];
}

@end
