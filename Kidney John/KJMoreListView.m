//
//  KJMoreListView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreListView.h"
#import "PBWebViewController.h"

@interface KJMoreListView ()

@end

@implementation KJMoreListView {
    NSArray *listItems;
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"moreItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [listItems objectAtIndex:indexPath.row];
    // Custom font
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    cell.textLabel.font = kjCustomFont;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check to see what link was clicked
    // REVIEW: cause this code kinda sucks
    NSURL *url = [[NSURL alloc] init];
    
    switch (indexPath.row) {
        case 0:
            url = [NSURL URLWithString:@"https://www.facebook.com/kidneyjohn"];
            NSLog(@"URL IS: %@", url);
            break;
        
        case 1:
            url = [NSURL URLWithString:@"https://twitter.com/kidneyjohn"];
            NSLog(@"URL IS: %@", url);
            break;
            
        case 2:
            url = [NSURL URLWithString:@"http://johnroderickpaine.tumblr.com"];
            NSLog(@"URL IS: %@", url);
            break;
            
        case 3:
            url = [NSURL URLWithString:@"https://www.youtube.com/user/kidneyjohn"];
            NSLog(@"URL IS: %@", url);
            break;
            
        case 4:
            url = [NSURL URLWithString:@"http://vimeo.com/johnroderickpaine"];
            NSLog(@"URL IS: %@", url);
            break;
            
        case 5:
            url = [NSURL URLWithString:@"http://instagram.com/johnroderickpaine"];
            NSLog(@"URL IS: %@", url);
            break;
            
        default:
            NSLog(@"NO URL");
            break;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Initialize the web view controller and set it's URL
    PBWebViewController *webViewController = [[PBWebViewController alloc] init];
    webViewController.URL = url;
    
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

#pragma mark - Prepare for segue

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"moreDetailSegue"]) {
//        // Set this in every view controller so that the back button displays back instead of the root view controller name
//        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        KJMoreDetailView *destViewController = segue.destinationViewController;
//        destViewController.nameFromList = [listItems objectAtIndex:indexPath.row];
//        
//        // Hide tabbar on detail view
//        destViewController.hidesBottomBarWhenPushed = YES;
//    }
//}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = @"Like, Comment, Subscribe";
    
    listItems = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Tumblr", @"YouTube", @"Vimeo", @"Instagram", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
