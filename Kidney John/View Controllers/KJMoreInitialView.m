//
//  KJMoreInitialView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreInitialView.h"
#import "PBWebViewController.h"
#import "JPLReachabilityManager.h"
#import "Reachability.h"
#import "KJSocialLink.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJSocialLinkCell.h"
#import <SafariServices/SafariServices.h>
#import "UIViewController+KJUtils.h"
#import "KJComic.h"
#import "KJVideo.h"
#import "Kidney_John-Swift.h"

// Constants
static NSString *kSegueIdentifierDoodleFavourite = @"doodleFavouriteSegue";
static NSString *kSegueIdentifierFavourite = @"favouritesSegue";

@interface KJMoreInitialView () <UITableViewDataSource, UITableViewDelegate>

// Properties
@property (nonatomic, strong) NSArray *cellArray;
@property (nonatomic) NSInteger chosenRow;
@property (nonatomic, strong) NSMutableArray *socialLinksArray;
@property (nonatomic) BOOL areWeTestingSocialLinksFromParseFeature;
@property (nonatomic, strong) UIAlertController *noNetworkAlertView;

@end

@implementation KJMoreInitialView

#pragma mark - dealloc method

- (void)dealloc {
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
    // TODO: refactor this after CloudKit
    if (_areWeTestingSocialLinksFromParseFeature == YES) {
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
    else if (indexPath.section == 1) {
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
            // Favourites section
            
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
            // Social media links section
            
            // GUARD - prevent if no network is available
            if ([JPLReachabilityManager isUnreachable]) {
                [tableView deselectRowAtIndexPath:indexPath
                                         animated:YES];
                
                // Show noNetworkAlertView
                NSString *okayButtonString = NSLocalizedString(@"Okay", @"Title of Okay button in No Network connection error alert");
                
                // NOTE - init using category method
                _noNetworkAlertView = [self kj_noNetworkAlertControllerWithNoActions];
                
                // Init actions
                UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okayButtonString
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:nil];
                
                [_noNetworkAlertView addAction:okayAction];
                
                [self presentViewController:_noNetworkAlertView
                                   animated:YES
                                 completion:nil];
                
                return;
            }
            
            // Check OS version; use Safari VC if iOS 9 or above
            NSOperatingSystemVersion iOS9 = (NSOperatingSystemVersion){9, 0, 0};
            BOOL isiOS9OrHigher = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS9];
//            DDLogVerbose(@"Is iOS 9 : %@", isiOS9OrHigher ? @"YES" : @"NO");
            
            // Init URL and title for web VC
            NSURL *url;
            NSString *title;
            
            // FOR TESTING
            if (_areWeTestingSocialLinksFromParseFeature == YES) {
                // Use Parse
                KJSocialLink *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
                url = [NSURL URLWithString:socialLink.url];
                title = socialLink.title;
            }
            else {
                // Use hardcoded social links
                NSDictionary *socialLink = [_socialLinksArray objectAtIndex:indexPath.row];
                url = [NSURL URLWithString:[socialLink objectForKey:@"url"]];
                title = [socialLink objectForKey:@"title"];
            }
            
            if (isiOS9OrHigher) {
                // Init web view controller
                SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url];
                webViewController.title = title;
                
                // Hide tabbar on detail view
                webViewController.hidesBottomBarWhenPushed = YES;
                
                
                // Push it
                [self.navigationController pushViewController:webViewController
                                                     animated:YES];
            }
            
            // iOS 8
            else {
                // Initialize the web view controller and set its' URL
                PBWebViewController *webViewController = [[PBWebViewController alloc] init];
                webViewController.URL = url;
                webViewController.title = title;
                
                // Hide tabbar on detail view
                webViewController.hidesBottomBarWhenPushed = YES;
                
                // Push it
                [self.navigationController pushViewController:webViewController
                                                     animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Prepare for segue method

- (NSArray *)returnVideoFavouritesArray {
    // Init predicate for videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by video date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoDate"
                                                                   ascending:NO];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Set predicate
    fetchRequest.predicate = predicate;
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
//        DDLogError(@"videoStore: error fetching favourites: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

- (NSArray *)returnComicFavouritesArray {
    // Init predicate for comics where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJComic class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by comic name)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comicName"
                                                                   ascending:NO];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Set predicate
    fetchRequest.predicate = predicate;
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
//        DDLogError(@"comicStore: error fetching favourites: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Videos or Comix
    if ([[segue identifier] isEqualToString:kSegueIdentifierFavourite]) {
        // NOTE - we use this as title for destination view controller
        // TODO: review this; it looks not right
        NSString *typeOfFavourite = [_cellArray objectAtIndex:_chosenRow];
        NSArray *favouritesDataToPass;
        
        // Init destination view controller
        FavouritesTableViewController *destViewController = segue.destinationViewController;
        destViewController.titleForView = typeOfFavourite;
        
        // Videos
        if (_chosenRow == 0) {
            favouritesDataToPass = [self returnVideoFavouritesArray];
        }
        
        // Comix
        else if (_chosenRow == 1) {
            favouritesDataToPass = [self returnComicFavouritesArray];
        }
        
        destViewController.cellResults = favouritesDataToPass;
        
    } else if ([[segue identifier] isEqualToString:kSegueIdentifierDoodleFavourite]) {
        FavouriteDoodlesViewController *destViewController = segue.destinationViewController;
        destViewController.managedObjectContext = self.managedObjectContext;
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
//        DDLogVerbose(@"%s: network became available", __func__);
        
        // Dismiss no network UIAlert
        // TODO: review this; doesn't seem to be working but isn't affecting anything right now except that the alert stays on-screen if network becomes reachable
        [_noNetworkAlertView dismissViewControllerAnimated:YES
                                                completion:nil];
        
        // Fetch data
        // TODO: revise this after CloudKit refactor
//        [[KJSocialLinkStore sharedStore] fetchSocialLinkData];
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
