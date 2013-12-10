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

#pragma mark return a random number
- (NSUInteger)generateRandomNumberFromArray:(NSMutableArray *)arrayToCount
{
    NSUInteger randomIndex = arc4random() % [arrayToCount count];
    
    return randomIndex;
}

#pragma mark get a random image from the array
- (UIImage *)getRandomImageFromArray
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    //NSUInteger randomIndex = arc4random() % [imageUrlResults count];
    //NSString *randomUrlString = [NSString stringWithFormat:@"%@", [imageUrlResults objectAtIndex:randomIndex]];
    NSString *randomUrlString = [NSString stringWithFormat:@"%@", [imageUrlResults objectAtIndex:[self generateRandomNumberFromArray:imageUrlResults]]];
    NSURL *url = [NSURL URLWithString:randomUrlString];
    
    UIImage *image = [[UIImage alloc] init];
    
    NSLog(@"RANDOM: URL selected - %@", url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:data];
    
    if ([randomUrlString isEqualToString:self.currentRandomImageUrl]) {
        NSLog(@"RANDOM: this image has just been displayed");
    }
    
    self.currentRandomImageUrl = [NSString stringWithFormat:@"%@", randomUrlString];
    NSLog(@"RANDOM: set currentRandomImageUrl to - %@", self.currentRandomImageUrl);
    
//    do {
//        NSLog(@"RANDOM: URL selected - %@", url);
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        image = [UIImage imageWithData:data];
//        self.currentRandomImageUrl = randomUrlString;
//    } while ([randomUrlString isEqualToString:self.currentRandomImageUrl]);
    
//    while ([randomUrlString isEqualToString:self.currentRandomImageUrl]) {
//        randomIndex = arc4random() % [imageUrlResults count];
//        randomUrlString = [NSString stringWithFormat:@"%@", [imageUrlResults objectAtIndex:randomIndex]];
//        url = [NSURL URLWithString:randomUrlString];
//        
//        NSLog(@"RANDOM: URL selected - %@", url);
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        image = [UIImage imageWithData:data];
//        self.currentRandomImageUrl = [NSString stringWithFormat:@"%@", randomUrlString];
//    }
    
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

#pragma mark UISwipeGesture methods
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
    
    //randomImageArray = nil;
    //randomImageArray = [NSMutableArray arrayWithObjects:@"http://distilleryimage4.ak.instagram.com/49b370cc5e6e11e3b8a7126a0592d374_8.jpg", @"http://distilleryimage9.ak.instagram.com/2c0c5672569111e3b7830afd819a2d90_8.jpg", @"http://distilleryimage6.ak.instagram.com/d6650f0a473d11e3ab0222000ab5be36_8.jpg", @"http://distilleryimage5.ak.instagram.com/3f3f05883ef811e3b93922000a1fb103_8.jpg", nil];
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        self.currentRandomImageUrl = [[NSString alloc] init];
        NSLog(@"RANDOM: init currentRandomImageUrl");
        NSLog(@"RANDOM: fetching image urls ...");
        [self fetchRandomImageUrls];
    });
    
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
