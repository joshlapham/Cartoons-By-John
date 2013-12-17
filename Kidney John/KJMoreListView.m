//
//  KJMoreListView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreListView.h"
#import "KJMoreDetailView.h"

@interface KJMoreListView ()

@property (nonatomic, strong) NSArray *listItems;

@end

@implementation KJMoreListView

@synthesize listItems;

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
    
    return cell;
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"moreDetailSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KJMoreDetailView *destViewController = segue.destinationViewController;
        destViewController.nameFromList = [listItems objectAtIndex:indexPath.row];
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark - Init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Like, Comment, Subscribe";
    
    listItems = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Tumblr", @"YouTube", @"Vimeo", @"Instagram", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
