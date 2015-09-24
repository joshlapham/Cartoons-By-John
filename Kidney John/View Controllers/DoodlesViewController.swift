//
//  DoodlesViewController.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

// TODO: update to use Cocoalumberjack for logging on this class

class DoodlesViewController: UICollectionViewController {
    // Properties
    var dataSource: KJRandomViewDataSource?
    var progressHud: MBProgressHUD?
    var backgroundImageView: UIImageView?
    var singleTap: UITapGestureRecognizer?
    var noNetworkAlertView: UIAlertController?
    
    // Methods
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = NSLocalizedString("Doodles", comment: "Title of view")
        
        // Register custom UICollectionViewCell
        self.collectionView?.registerClass(KJDoodleCell.classForCoder(), forCellWithReuseIdentifier: KJDoodleCell.cellIdentifier())
        
        // Register for NSNotifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("doodleFetchDidHappen"), name: KJDoodleFetchDidHappenNotification, object: nil)
        
        // Reachability NSNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityDidChange"), name: kReachabilityChangedNotification, object: nil)
        
        // Fetch doodle data
        self.fetchDataWithNetworkCheck()
        
        // Set background if no network is available
        if JPLReachabilityManager.isUnreachable() == true {
            // Init background image for collectionView
            self.backgroundImageView = self.kj_noNetworkImageView()
            self.collectionView?.backgroundView = self.backgroundImageView
            self.collectionView?.backgroundView?.contentMode = .ScaleAspectFit
            
            // Gesture recognizer to reload data if tapped
            self.singleTap = UITapGestureRecognizer(target: self, action: Selector("fetchDataWithNetworkCheck"))
            self.singleTap?.numberOfTapsRequired = 1
            self.collectionView?.addGestureRecognizer(self.singleTap!)
        }
        
        // Setup collection view
        self.setupCollectionView()
    }
}

// MARK: - Data fetch methods
extension DoodlesViewController {
    func fetchDataWithNetworkCheck() {
        // Show progress
        // Init MBProgressHUD
        self.progressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.progressHud?.userInteractionEnabled = false
        let progressHudString = NSLocalizedString("Loading Doodles ...", comment: "Message shown under progress wheel when doodles (drawings) are loading")
        self.progressHud?.labelText = progressHudString
        self.progressHud?.labelFont = UIFont.kj_progressHudFont()
        
        // Show network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Check if first doodle data fetch has happened
        if NSUserDefaults.kj_hasFirstDoodleFetchCompletedSetting() == false {
            // Check if network is reachable
            if JPLReachabilityManager.isReachable() == true {
                KJDoodleStore.sharedStore().fetchDoodleData()
            } else if JPLReachabilityManager.isUnreachable() == true {
                // Show noNetworkAlertView
                self.noNetworkConnection()
            }
            
        } else {
            // We have data, so call this method to fetch from local DB and reload table
            self.doodleFetchDidHappen()
            
            // Fetch new data if network is available
            if JPLReachabilityManager.isReachable() == true {
                KJDoodleStore.sharedStore().fetchDoodleData()
            }
        }
    }
    
    func doodleFetchDidHappen() {
        //        DDLogVerbose(@"%s: data fetch did happen", __func__);
        
        // Init data source array
        self.dataSource?.cellDataSource = KJDoodleStore.sharedStore().returnDoodlesArray()
        
        // TODO: testing flow layout toggle
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("toggleLayouts:"))
        
        // Hide progress
        self.progressHud?.hide(true)
        
        // Hide network activity monitor
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Set background of collectionView to nil to remove any network error image showing
        if self.backgroundImageView?.hidden == false {
            self.backgroundImageView?.removeFromSuperview()
            self.collectionView?.backgroundView = nil
        }
        
        // Remove tap gesture recognizer
        if let tap = self.singleTap {
            self.collectionView?.removeGestureRecognizer(tap)
        }
        
        // Reload collectionView data
        self.collectionView?.reloadData()
    }
    
    func noNetworkConnection() {
        // Init strings for noNetworkAlertView
        let cancelButtonString = NSLocalizedString("Cancel", comment: "Title of Cancel button in No Network connection error alert")
        let retryButtonString = NSLocalizedString("Retry", comment: "Title of Retry button in No Network connection error alert")
        
        // Init alertView
        self.noNetworkAlertView = self.kj_noNetworkAlertControllerWithNoActions()
        
        // Init actions
        // Retry
        let retryAction = UIAlertAction(title: retryButtonString, style: .Default) { (action: UIAlertAction) -> Void in
            // Retry data fetch
            self.fetchDataWithNetworkCheck()
        }
        
        self.noNetworkAlertView?.addAction(retryAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: cancelButtonString, style: .Cancel) { (action: UIAlertAction) -> Void in
            // Reload collectionView data to check for empty data source
            self.collectionView?.reloadData()
        }
        
        self.noNetworkAlertView?.addAction(cancelAction)
        
        // Check if first doodle data fetch has happened
        if NSUserDefaults.kj_hasFirstDoodleFetchCompletedSetting() == false {
            // Hide progress
            self.progressHud?.hide(true)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            // Show alertView
            if let alert = self.noNetworkAlertView {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Helper methods
extension DoodlesViewController {
    func setupCollectionView() {
        // NOTE - this ensures correct layout after changing collectionView layout
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Accessibility
        if (UIAccessibilityDarkerSystemColorsEnabled()) {
            self.collectionView?.backgroundColor = UIColor.kj_accessibilityDarkenColoursBackgroundColour()
        } else {
            self.collectionView?.backgroundColor = UIColor.kj_viewBackgroundColour()
        }
        
        // Init flow layout
        // TODO: testing flow layout toggle
        //                let flowLayout = SwipeFlowLayout(forCollectionView: self.collectionView)
        let flowLayout = GridFlowLayout(forCollectionView: self.collectionView)
        self.collectionView?.collectionViewLayout = flowLayout
        
        // Init data source
        self.dataSource = KJRandomViewDataSource()
        
        // Set delegates
        self.collectionView?.dataSource = self.dataSource
        self.collectionView?.delegate = self
    }
    
    func reachabilityDidChange() {
        if JPLReachabilityManager.isReachable() == true {
            //            DDLogVerbose(@"Doodles: network became available");
            
            // Dismiss no network UIAlert
            self.noNetworkAlertView?.dismissViewControllerAnimated(true, completion: nil)
            
            // Fetch data
            KJDoodleStore.sharedStore().fetchDoodleData()
        }
    }
}

// MARK: - UICollectionViewDelegate methods
extension DoodlesViewController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: implement `guard`s here (prevent force unwrap)
        
        let cellData = self.dataSource?.cellDataSource[indexPath.row] as? KJRandomImage
        
        let storyboard = UIStoryboard(name: "ImageStoryboard", bundle: nil)
        let destViewController = storyboard.instantiateViewControllerWithIdentifier("SingleImageViewController") as? SingleImageViewController
        destViewController?.imageToShow = cellData
        destViewController?.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(destViewController!, animated: true)
    }
}

// TODO: testing flow layout toggle
//// MARK: - Toggle flow layout helper methods
//extension DoodlesViewController {
//    @IBAction func toggleLayouts(sender: AnyObject) {
//        // TODO: calculate contentOffset and adjust accordingly
//        // NOTE - when switching from grid to swipe layout, cells can be placed slightly off screen and need to snap back in place.
//        //        print("CV CONTENT OFFSET : \(self.collectionView?.contentOffset)")
//
//        // NOTE - this still seems to animate layout change
//        let shouldAnimateLayoutChange = false
//
//        if self.collectionView?.collectionViewLayout is SwipeFlowLayout {
//            let flowLayout = GridFlowLayout(forCollectionView: self.collectionView)
//            self.collectionView?.setCollectionViewLayout(flowLayout, animated: shouldAnimateLayoutChange)
//            self.collectionView?.delegate = flowLayout
//
//        } else if self.collectionView?.collectionViewLayout is GridFlowLayout {
//            let flowLayout = SwipeFlowLayout(forCollectionView: self.collectionView)
//            self.collectionView?.setCollectionViewLayout(flowLayout, animated: shouldAnimateLayoutChange)
//            self.collectionView?.delegate = flowLayout
//        }
//
//        // NOTE - not sure if this has any effect
//        self.collectionView?.collectionViewLayout.invalidateLayout()
//
//        NSNotificationCenter.defaultCenter().postNotificationName("DoodlesLayoutDidChange", object: nil)
//    }
//}