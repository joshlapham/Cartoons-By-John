//
//  KJMoreInitialView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreInitialView.h"
#import "KJFavouritesListView.h"
#import "KJMoreListView.h"
#import "PBWebViewController.h"

@interface KJMoreInitialView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation KJMoreInitialView {
    NSArray *cellArray;
    NSArray *socialCellArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            {
                return 1;
            }
            break;
        
        case 1:
            {
                return [socialCellArray count];
            }
            break;
            
        default:
            break;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            //NSLog(@"section 0");
            return [NSString stringWithFormat:@"Favourites"];
            break;
            
        case 1:
            //NSLog(@"section 1");
            return [NSString stringWithFormat:@"Like, Comment, Subscribe"];
            break;
            
        default:
            return [NSString stringWithFormat:@"LOL error"];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set custom font
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    cell.textLabel.font = kjCustomFont;
    
    // Set image to show next to item
    switch (indexPath.section) {
        case 0:
            // set Favourites icon here
            //cell.imageView.image = something something
            // Set the cell text
            cell.textLabel.text = [cellArray objectAtIndex:indexPath.row];
            break;
            
        case 1:
            // set Social Media icon here
            // Set the cell text
            cell.textLabel.text = [socialCellArray objectAtIndex:indexPath.row];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            {
                [self performSegueWithIdentifier:@"favouritesSegue" sender:self];
            }
            break;
            
        case 1:
            {
                //[self performSegueWithIdentifier:@"socialSegue" sender:self];
                
                // Set back button to have no text
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                
                // Initialize the web view controller and set it's URL
                PBWebViewController *webViewController = [[PBWebViewController alloc] init];
                webViewController.URL = [self returnUrlForItemAtPath:indexPath];
                
                // These are custom UIActivity subclasses that will show up in the UIActivityViewController
                // when the action button is clicked
                //PBSafariActivity *activity = [[PBSafariActivity alloc] init];
                //webViewController.applicationActivities = @[activity];
                
                // This property also corresponds to the same one on UIActivityViewController
                // Both properties do not need to be set unless you want custom actions
                //webViewController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToWeibo];
                
                // Hide tabbar on detail view
                webViewController.hidesBottomBarWhenPushed = YES;
                
                // Push it
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //self.title = @"More";
    
    cellArray = [NSArray arrayWithObjects:@"Favourites List", nil];
    socialCellArray = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Tumblr", @"YouTube", @"Vimeo", @"Instagram", nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    
    // dealloc navbar label here
    self.navigationItem.titleView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    // Set title
    self.title = @"More";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    cellArray = nil;
}

#pragma mark - Social media URL method

- (NSURL *)returnUrlForItemAtPath:(NSIndexPath *)indexPath
{
    // Check to see what link was clicked
    // REVIEW: cause this code kinda sucks
    switch (indexPath.row) {
        case 0:
            return [NSURL URLWithString:@"https://www.facebook.com/kidneyjohn"];
            break;
            
        case 1:
            return [NSURL URLWithString:@"https://twitter.com/kidneyjohn"];
            break;
            
        case 2:
            return [NSURL URLWithString:@"http://johnroderickpaine.tumblr.com"];
            break;
            
        case 3:
            return [NSURL URLWithString:@"https://www.youtube.com/user/kidneyjohn"];
            break;
            
        case 4:
            return [NSURL URLWithString:@"http://vimeo.com/johnroderickpaine"];
            break;
            
        case 5:
            return [NSURL URLWithString:@"http://instagram.com/johnroderickpaine"];
            break;
            
        default:
            NSLog(@"Error: no URL");
            return nil;
            break;
    }
}

@end
