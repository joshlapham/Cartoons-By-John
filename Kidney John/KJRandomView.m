//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "Parse.h"
#import "Models/KJRandomImage.h"
#import "MBProgressHUD.h"

@interface KJRandomView ()

@property (nonatomic, strong) NSString *currentRandomImageUrl;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureRecognizer;

@end

@implementation KJRandomView

@synthesize randomImageArray, randomImage, imageIdResults, imageUrlResults, imageDescriptionResults, imageDateResults;

#pragma mark fetch the random image URLs
- (void)fetchRandomImageUrls
{
    // Fetch locations
    // Query Location Parse class
    PFQuery *query = [PFQuery queryWithClassName:@"RandomImage"];
    
    // Query all videos
    [query whereKey:@"imageDescription" notEqualTo:@"LOL"];
    
    // Init result arrays
    imageUrlResults = [[NSMutableArray alloc] init];
    //randomImageArray = [[NSMutableArray alloc] init];
    
    // Start query with block
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
            // Do something with the found objects
            
            for (PFObject *object in objects) {
                if ([object[@"is_active"] isEqual:@"1"]) {
                    NSString *imageUrlString = [NSString stringWithFormat:@"%@", object[@"imageUrl"]];
                    [imageUrlResults addObject:imageUrlString];
                    
                    NSLog(@"RANDOM: URL added to array: %@", imageUrlString);
                }
            }
            NSLog(@"RANDOM: URL array count: %lu", (unsigned long)[imageUrlResults count]);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        self.randomImage.image = [self getRandomImageFromArray];
        //[self.view setNeedsDisplay];
    }];

}

#pragma mark return random URL string from array
- (NSString *)getRandomImageUrlFromGivenArray:(NSMutableArray *)arrayToCheck
{
    NSString *stringToReturn = [[NSString alloc] init];
    
    // Get random URL if it wasn't just displayed
    do {
        NSUInteger randomIndex = arc4random() % [arrayToCheck count];
        stringToReturn = [NSString stringWithFormat:@"%@", [arrayToCheck objectAtIndex:randomIndex]];
    } while ([stringToReturn isEqualToString:self.currentRandomImageUrl]);
    
    // Set last URL variable to the URL string we're using
    self.currentRandomImageUrl = stringToReturn;
    
    return stringToReturn;
}

#pragma mark get a random image from array
- (UIImage *)getRandomImageFromArray
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    // Init URL string using method call to get random URL from array
    NSString *randomUrlString = [NSString stringWithFormat:@"%@", [self getRandomImageUrlFromGivenArray:imageUrlResults]];
    
    NSURL *url = [NSURL URLWithString:randomUrlString];
    NSLog(@"RANDOM: URL selected - %@", url);
    UIImage *image = [[UIImage alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:data];
    
    if (image != nil) {
        NSLog(@"RANDOM: image loaded from URL");
        
        // Hide progress
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        return image;
    } else {
        NSLog(@"RANDOM: error - image not loaded from URL");
        
        // Hide progress
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        return nil;
    }
}

#pragma mark UISwipeGesture method
- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"RANDOM: swipe received");
    if ([[self imageUrlResults] count] != 0) {
        self.randomImage.image = [self getRandomImageFromArray];
    } else {
        NSLog(@"RANDOM: error - swipeHandler could not load an image due to an empty image URL array");
    }
}

#pragma mark view methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Random";
    
    // Fetch image URLs from Parse
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        self.currentRandomImageUrl = [[NSString alloc] init];
        NSLog(@"RANDOM: init currentRandomImageUrl");
        NSLog(@"RANDOM: fetching image urls ...");
        [self fetchRandomImageUrls];
    });
    
    // Init swipe gesture recognizer for image view
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.randomImage addGestureRecognizer:self.gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[self imageUrlResults] count] != 0) {
        self.randomImage.image = [self getRandomImageFromArray];
    } else {
        NSLog(@"RANDOM: error - viewWillAppear could not load an image due to an empty image URL array");
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.randomImage.image = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.randomImage.image = nil;
    self.imageUrlResults = nil;
}

@end
