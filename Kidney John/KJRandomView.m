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

@end

@implementation KJRandomView

@synthesize randomImageArray, randomImage, imageIdResults, imageUrlResults, imageDescriptionResults, imageDateResults;

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
            
            //self.videosArrayToSendToDelegate = [NSMutableArray array];
            
            for (PFObject *object in objects) {
                NSString *imageUrlString = [NSString stringWithFormat:@"%@", object[@"imageUrl"]];
                [imageUrlResults addObject:imageUrlString];
                
                NSLog(@"RANDOM: url added to array: %@", imageUrlString);
                NSLog(@"RANDOM: url array count: %lu", (unsigned long)[imageUrlResults count]);
                
                
                // PFClass for locations
//                KJRandomImage *randomImage = [[KJRandomImage alloc] init];
//                [randomImage setImageId:object[@"imageId"]];
//                [randomImage setImageUrl:object[@"imageUrl"]];
//                [randomImage setImageDescription:object[@"imageDescription"]];
                
//                // Date
//                NSString *dateString = object[@"date"];
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                dateFormatter.dateFormat = @"yyyy-MM-dd";
//                NSDate *formattedDate = [dateFormatter dateFromString:dateString];
//                dateFormatter.dateFormat = @"dd-MMM-yyyy";
//                
//                // DEBUGGING - log correctly formatted date
//                //NSLog(@"%@",[dateFormatter stringFromDate:formattedDate]);
//                
//                // Add newly formatted date
//                //[video setVideoDate:object[@"date"]];
//                [randomImage setImageDate:formattedDate];
                
                //__block NSMutableArray *videosArrayToSendToDelegate = [[NSMutableArray alloc] init];
                //[locations addObject:location];
                
                //[[self videosArrayToSendToDelegate] addObject:video];
                
                //NSLog(@"LOCATIONS OBJECT: %@", location);
                //[videoProtocol updateVideosArrayWithVideo:video];
                //NSLog(@"LOCATIONS ARRAY: %@", [dayOfWeekProto locationsArray]);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        // Set delegate's locations array
        //[videoProtocol setVideosArray:[self videosArrayToSendToDelegate]];
        //NSLog(@"Fetched and stored a total of %lu videos", (unsigned long)[[videoProtocol videosArray] count]);
        
        //[dayOfWeekProto returnLocationForGivenWeekday:@"Monday"];
        //[dayOfWeekProto returnLocationForGivenWeekday:@"Wednesday"];
        //                [dayOfWeekProto updateCurrentUserLocationWithGeoPoint:geoPoint];
        
        self.randomImage.image = [self getRandomImageFromArray];
        //[self.view setNeedsDisplay];
    }];

}

- (UIImage *)getRandomImageFromArray
{
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"";
    
    NSUInteger randomIndex = arc4random() % [imageUrlResults count];
    NSURL *url = [NSURL URLWithString:[imageUrlResults objectAtIndex:randomIndex]];
    NSLog(@"RANDOM: URL selected - %@", url);
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
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

- (UIImage *)getRandomImageFromArrayWithView:(UIView *)view
{
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Random";
    
    //randomImageArray = nil;
    //randomImageArray = [NSMutableArray arrayWithObjects:@"http://distilleryimage4.ak.instagram.com/49b370cc5e6e11e3b8a7126a0592d374_8.jpg", @"http://distilleryimage9.ak.instagram.com/2c0c5672569111e3b7830afd819a2d90_8.jpg", @"http://distilleryimage6.ak.instagram.com/d6650f0a473d11e3ab0222000ab5be36_8.jpg", @"http://distilleryimage5.ak.instagram.com/3f3f05883ef811e3b93922000a1fb103_8.jpg", nil];
    
    [self fetchRandomImageUrls];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    if (randomImageArray != nil) {
//        randomImage.image = [self getRandomImageFromArray];
//    }
    
    [self fetchRandomImageUrls];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.randomImage.image = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
