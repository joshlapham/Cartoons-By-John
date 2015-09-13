//
//  KJMoreInitialView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreInitialView.h"
#import "KJFavouritesListView.h"
#import "PBWebViewController.h"
#import "KJVideoStore.h"
#import "KJComicStore.h"
//#import "KJDoodleStore.h"
#import "KJSocialLinkStore.h"
//#import "KJFavDoodlesListView.h"
#import "JPLReachabilityManager.h"
#import <Reachability/Reachability.h>
#import "KJSocialLink.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJSocialLinkCell.h"
#import "KJSecretLoginViewController.h"
#import <Parse/Parse.h>

// TODO: remove import after testing feature
#import "KJSecretAdminViewController.h"

// Constants
static NSString *kSegueIdentifierDoodleFavourite = @"doodleFavouriteSegue";
static NSString *kSegueIdentifierFavourite = @"favouritesSegue";

@interface KJMoreInitialView () <UITableViewDataSource, UITableViewDelegate>

// Properties
@property (nonatomic, strong) NSArray *cellArray;
@property (nonatomic) NSInteger chosenRow;
@property (nonatomic, strong) NSMutableArray *socialLinksArray;
@property (nonatomic) BOOL areWeTestingSocialLinksFromParseFeature;

@end

@implementation KJMoreInitialView

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJSocialLinkDataFetchDidHappenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}


#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = NSLocalizedString(@"More", @"Title of More view");
    
    // FOR TESTING of fetching Social Link data from Parse
    _areWeTestingSocialLinksFromParseFeature = NO;
    
    // Use links from Parse
    if (_areWeTestingSocialLinksFromParseFeature == YES) {
        // Set up NSNotification receiving for when socialLinkStore finishes data fetch
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFetchSocialLinks)
                                                     name:KJSocialLinkDataFetchDidHappenNotification
                                                   object:nil];
        
        // Reachability NSNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityDidChange)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // Init cell array
        [self initSocialLinksArrayFromParse];
    }
    
    // Use hardcoded links
    else {
        [self initHardcodedSocialLinksArray];
    }
    
    // Init strings for Favourites cells
    // NOTE: these strings will be used as titles for their respective views when tapped
    NSString *videosString = NSLocalizedString(@"Videos", @"Title of Videos button for Favourites list");
    NSString *comicString = NSLocalizedString(@"Comix", @"Title of Comics button for Favourites list");
    NSString *doodlesString = NSLocalizedString(@"Doodles", @"Title of Doodles button for Favourites list");
    
    // Init array of titles for Favourites cells
    _cellArray = [NSArray arrayWithObjects:videosString, comicString, doodlesString, nil];
    
    // Set properties on tableView
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        self.tableView.backgroundColor = [UIColor kj_accessibilityDarkenColoursBackgroundColour];
    }
    
    else {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    // Register cells with tableView
    [self.tableView registerNib:[UINib nibWithNibName:[KJSocialLinkCell cellIdentifier]
                                               bundle:nil]
         forCellReuseIdentifier:[KJSocialLinkCell cellIdentifier]];
    
    // Allow for dynamic sized cells
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - UITableView delegate methods

// TODO: refactor to own data source class

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [_cellArray count];
            break;
            
        case 1:
            return [_socialLinksArray count];
            break;
            
        default:
            break;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    KJSocialLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:[KJSocialLinkCell cellIdentifier]
                                                             forIndexPath:indexPath];
    
    // Init properties for cell label values
    NSString *titleString;
    UIImage *cellImage;
    
    // Determine section (Favourites or Social Links)
    // If Favourites section ..
    if (indexPath.section == 0) {
        // Init properties for cell label values
        titleString = [_cellArray objectAtIndex:indexPath.row];
        
        // Set Favourites icon
        // Videos
        if (indexPath.row == 0) {
            cellImage = [UIImage imageNamed:@"video-tab-icon.png"];
        }
        
        // Comics
        else if (indexPath.row == 1) {
            cellImage = [UIImage imageNamed:@"comic-tab-icon.png"];
        }
        
        // Doodles
        else if (indexPath.row == 2) {
            cellImage = [UIImage imageNamed:@"doodle-tab-icon.png"];
        }
        
        // Set cell type
        [cell setCellType:KJSocialLinkCellTypeFavourites];
        
        // Configure cell
        [cell configureCellWithTitle:titleString
                            andImage:cellImage];
    }
    
    // If Social Links section ..
    else {
        // Set the cell text
        // FOR TESTING
        // Use links from Parse
        if (_areWeTestingSocialLinksFromParseFeature == YES) {
            KJSocialLink *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
            titleString = socialLink.title;
            cellImage = [UIImage imageNamed:socialLink.imagePath];
        }
        
        // Use hardcoded social links
        else {
            NSDictionary *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
            titleString = [socialLink objectForKey:@"title"];
            cellImage = [UIImage imageNamed:[socialLink objectForKey:@"image"]];
        }
        
        // Set cell type
        [cell setCellType:KJSocialLinkCellTypeSocialLink];
        
        // Configure cell
        [cell configureCellWithTitle:titleString
                            andImage:cellImage];
    }
    
    return cell;
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            _chosenRow = indexPath.row;
            
            // If Doodles was tapped ..
            if (_chosenRow == 2) {
                // Doodles was chosen
                [self performSegueWithIdentifier:kSegueIdentifierDoodleFavourite
                                          sender:self];
            }
            
            // Videos or Comix was chosen
            else {
                [self performSegueWithIdentifier:kSegueIdentifierFavourite
                                          sender:self];
            }
        }
            break;
            
        case 1:
        {
            // Social media links
            // Set back button to have no text
            // TODO: review this, not really best practice
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
            
            // Initialize the web view controller and set it's URL
            PBWebViewController *webViewController = [[PBWebViewController alloc] init];
            
            // FOR TESTING
            if (_areWeTestingSocialLinksFromParseFeature == YES) {
                // Use Parse
                KJSocialLink *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
                webViewController.URL = [NSURL URLWithString:socialLink.url];
                webViewController.title = socialLink.title;
            }
            else {
                // Use hardcoded social links
                NSDictionary *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
                webViewController.URL = [NSURL URLWithString:[socialLink objectForKey:@"url"]];
                webViewController.title = [socialLink objectForKey:@"title"];
            }
            
            // Hide tabbar on detail view
            webViewController.hidesBottomBarWhenPushed = YES;
            
            // Push it
            [self.navigationController pushViewController:webViewController
                                                 animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Secret Admin VC methods

-       (CGFloat)tableView:(UITableView *)tableView
  heightForFooterInSection:(NSInteger)section {
    if (section != 1) {
        return 0;
    }
    
    else {
        return 25;
    }
}

// TODO: disabled for App Store release (for now)
//-   (UIView *)tableView:(UITableView *)tableView
// viewForFooterInSection:(NSInteger)section {
//    if (section != 1) {
//        return nil;
//    }
//    
//    else {
//        // Init footer view
//        CGRect secretTapViewFrame = CGRectMake(tableView.tableFooterView.bounds.origin.x, tableView.tableFooterView.bounds.origin.y, tableView.tableFooterView.bounds.size.width, tableView.tableFooterView.bounds.size.height);
//        UIView *secretTapView = [[UIView alloc] initWithFrame:secretTapViewFrame];
//        
//        // Set background colour
//        secretTapView.backgroundColor = [UIColor clearColor];
//        
//        // Init secret tap gesture
//        // TODO: update this to be complex!
//        UITapGestureRecognizer *secretGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                        action:@selector(userDidPerformSecretGesture:)];
//        secretGesture.numberOfTapsRequired = 13;
//        [secretTapView addGestureRecognizer:secretGesture];
//        
//        return secretTapView;
//    }
//}

- (IBAction)userDidPerformSecretGesture:(id)sender {
    DDLogVerbose(@"%s", __func__);
    DDLogVerbose(@"%s - %@", __func__, [PFUser currentUser].debugDescription);
    
    // User is logged-in
    // TODO: review this for security
    if ([PFUser currentUser].username.length) {
        KJSecretAdminViewController *secretAdminVC = [[KJSecretAdminViewController alloc] init];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:secretAdminVC];
        
        // Present modally
        [self presentViewController:navCon
                           animated:YES
                         completion:nil];
    }
    
    // User is NOT logged-in
    else {
        // Init secret login VC
        KJSecretLoginViewController *secretLoginViewController = [[KJSecretLoginViewController alloc] init];
        
        // Present modally
        [self.navigationController presentViewController:secretLoginViewController
                                                animated:YES
                                              completion:nil];
    }
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Videos or Comix
    if ([[segue identifier] isEqualToString:kSegueIdentifierFavourite]) {
        // NOTE - we use this as title for destination view controller
        // TODO: review this; it looks not right
        NSString *typeOfFavourite = [_cellArray objectAtIndex:_chosenRow];
        NSArray *favouritesDataToPass;
        
        // Init destination view controller
        KJFavouritesListView *destViewController = segue.destinationViewController;
        destViewController.titleForView = typeOfFavourite;
        
        // Videos
        if (_chosenRow == 0) {
            favouritesDataToPass = [[KJVideoStore sharedStore] returnFavouritesArray];
        }
        
        // Comix
        else if (_chosenRow == 1) {
            favouritesDataToPass = [[KJComicStore sharedStore] returnFavouritesArray];
        }
        
        destViewController.cellResults = favouritesDataToPass;
    }
}

#pragma mark TableView header views

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Favourites", @"Header title for Favourites buttons in More view");
            break;
            
        case 1:
            return NSLocalizedString(@"Like, Comment, Subscribe", @"Header title for social media buttons in More view");
            break;
            
        default:
            // NOTE: returning nil by default
            return nil;
            break;
    }
}

-       (CGFloat)tableView:(UITableView *)tableView
  heightForHeaderInSection:(NSInteger)section {
    return 35;
}

-   (UIView *)tableView:(UITableView *)tableView
 viewForHeaderInSection:(NSInteger)section {
    // Init header label
    UILabel *headerLabel = [[UILabel alloc] init];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect headerLabelFrame = CGRectMake(20, 8, screenFrame.size.width, 20);
    headerLabel.frame = headerLabelFrame;
    
    // Set font and text
    headerLabel.font = [UIFont kj_sectionHeaderFont];
    headerLabel.text = [self tableView:tableView
               titleForHeaderInSection:section];
    
    // Set colour
    // Accessibility
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        headerLabel.textColor = [UIColor whiteColor];
    }
    
    else {
        headerLabel.textColor = [UIColor kj_moreViewSectionTextColour];
    }
    
    // Init view for section
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange {
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"%s: network became available", __func__);
        
        // Fetch data
        [[KJSocialLinkStore sharedStore] fetchSocialLinkData];
    }
}

#pragma mark - Init data source array method

// TODO: remove this once switched over to Parse for fetching social links

- (void)initHardcodedSocialLinksArray {
    NSDictionary *facebookLink = @{ @"title" : @"Facebook",
                                    @"url" : @"https://www.facebook.com/kidneyjohn",
                                    @"image" : @"facebook.png" };
    NSDictionary *twitterLink = @{ @"title" : @"Twitter",
                                   @"url" : @"https://twitter.com/johnrodpaine",
                                   @"image" : @"twitter.png" };
    NSDictionary *tumblrLink = @{ @"title" : @"Tumblr",
                                  @"url" : @"http://johnroderickpaine.tumblr.com",
                                  @"image" : @"tumblr.png" };
    NSDictionary *youtubeLink = @{ @"title" : @"YouTube",
                                   @"url" : @"https://www.youtube.com/user/johnroderickpaine",
                                   @"image" : @"youtube.png" };
    NSDictionary *vimeoLink = @{ @"title" : @"Vimeo",
                                 @"url" : @"http://vimeo.com/johnroderickpaine",
                                 @"image" : @"vimeo.png" };
    NSDictionary *instaLink = @{ @"title" : @"Instagram",
                                 @"url" : @"http://instagram.com/johnroderickpaine",
                                 @"image" : @"instagram.png" };
    NSDictionary *societyLink = @{ @"title" : @"Society6",
                                   @"url" : @"http://society6.com/kidneyjohn",
                                   @"image" : @"society6.png" };
    
    _socialLinksArray = [[NSMutableArray alloc] init];
    [_socialLinksArray addObject:facebookLink];
    [_socialLinksArray addObject:twitterLink];
    [_socialLinksArray addObject:tumblrLink];
    [_socialLinksArray addObject:youtubeLink];
    [_socialLinksArray addObject:vimeoLink];
    [_socialLinksArray addObject:instaLink];
    [_socialLinksArray addObject:societyLink];
}

#pragma mark - Social links from Parse methods

// NOTE - since we are still testing fetching of Social Links from Parse,
// these methods are commented out

#pragma mark Did fetch social links method

- (void)didFetchSocialLinks {
    //    DDLogVerbose(@"More: did fetch social links");
    //
    //    // Clear out existing links
    //    [_socialLinksArray removeAllObjects];
    //
    //    // Get links from Core Data
    //    _socialLinksArray = [NSMutableArray arrayWithArray:[KJSocialLink MR_findAll]];
    //
    //    // Reload tableView
    //    [self.tableView reloadData];
}

#pragma mark Init cell array methods

- (void)initSocialLinksArrayFromParse {
    //    // Init social link data source array
    //    _socialLinksArray = [NSMutableArray arrayWithArray:[KJSocialLink MR_findAll]];
    //
    //    // Reload tableView
    //    [self.tableView reloadData];
    //
    //    // Check if network is reachable
    //    if ([JPLReachabilityManager isReachable]) {
    //        // Fetch social links from Parse
    //        [[KJSocialLinkStore sharedStore] fetchSocialLinkData];
    //    }
}

@end
