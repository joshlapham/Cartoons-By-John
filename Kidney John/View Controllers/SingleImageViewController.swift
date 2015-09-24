//
//  SingleImageViewController.swift
//  Kidney John
//
//  Created by Josh Lapham on 23/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation
import UIKit

// TODO: update to use Cocoalumberjack for logging on this class
// TODO: implement accessibility on this class

class SingleImageViewController: UIViewController {
    // Properties
    var imageToShow: AnyObject?
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    // Methods
    // View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE - `title` for this VC is set in `setImageForView` method after `imageToShow` data type has been determined.
        
        self.view.backgroundColor = UIColor.kj_viewBackgroundColour()
        
        // Set image for view
        do {
            try self.setImageForView()
            
            // Init navbar action button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("showActivityView"))
            
        } catch SetImageError.NoImageSetForView {
            print("ERROR : no image set for view!")
        } catch SetImageError.NoImageViewForView {
            print("ERROR : no imageView set for view!")
        } catch {
            print("ERROR : \(error)")
        }
    }
}

// MARK: - Helper methods to set image for view
extension SingleImageViewController {
    // TODO: move all `ErrorType` structs to own file
    private enum SetImageError: ErrorType {
        case NoImageSetForView
        case NoImageViewForView
    }
    
    private func setImageForView() throws {
        guard let image = self.imageToShow else { throw SetImageError.NoImageSetForView }
        // TODO: do we need this `guard`? this error doesn't really happen anymore
        guard let imageView = self.imageView else { throw SetImageError.NoImageViewForView }
        
        // NOTE - this ensures image will scale correctly when device rotates
        imageView.contentMode = .ScaleAspectFit
        
        // Determine data type of `imageToShow`
        if image is KJRandomImage {
            // NOTE - we know `image` is of type `KJRandomImage` so we can force unwrap
            let image = image as! KJRandomImage
            
            self.title = NSLocalizedString("Doodle", comment: "Title of view")
            
            let imageUrl = NSURL(string: image.imageUrl)!
            
            // Set image with SDWebImage
            imageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
            
            // Track doodle viewed with Parse Analytics (if enabled)
            if NSUserDefaults.kj_shouldTrackViewedDoodleEventsWithParseSetting() {
                KJParseAnalyticsStore.sharedStore().trackDoodleViewEventForDoodle(image)
            }
            
        } else if image is KJComic {
            // NOTE - we know `image` is of type `KJComic` so we can force unwrap
            let image = image as! KJComic
            
            // Set title for VC to comic name
            if let title = image.comicName {
                // NOTE - not using a localized string here, because this string could be anything
                self.title = title
            }
            
            imageView.image = image.returnComicImageFromComic()
            
            // Track comic viewed with Parse Analytics (if enabled)
            if NSUserDefaults.kj_shouldTrackViewedComicEventsWithParseSetting() {
                KJParseAnalyticsStore.sharedStore().trackComicViewEventForComic(image)
            }
        }
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.delegate = self
        
        // Allow gesture recognisers to be recognised
        self.imageView.userInteractionEnabled = true
        
        // Double tap for zooming image in/out
        let doubleTap = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTap"))
        doubleTap.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(doubleTap)
        
        // Single tap for toggling navbar and status bar visibility
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap"))
        singleTap.numberOfTapsRequired = 1
        self.imageView.addGestureRecognizer(singleTap)
        
        // Differentiate between single tap and double tap
        singleTap.requireGestureRecognizerToFail(doubleTap)
    }
}

// MARK: - Image zoom methods
extension SingleImageViewController: UIScrollViewDelegate {
    // UIScrollView delegate method
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // Method to handle double tap on image and control zooming in/out
    func handleDoubleTap() {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    // Method to handle single tap on image which toggles navbar and status visibility
    func handleSingleTap() {
        guard let navController = self.navigationController else { return }
        
        // Toggle navbar
        let navBarVisible = !navController.navigationBarHidden
        navController.setNavigationBarHidden(navBarVisible, animated: true)
        
        // Toggle status bar
        let statusBarVisible = !UIApplication.sharedApplication().statusBarHidden
        UIApplication.sharedApplication().setStatusBarHidden(statusBarVisible, withAnimation: .Slide)
    }
}

// MARK: - UIActivityView methods
extension SingleImageViewController {
    func showActivityView() {
        // TODO: should we be returning out of `guard` statements?
        // TODO: UIActivityVC logic here could be refactored to not double up on code
        
        guard let cellData = self.imageToShow else { return }
        
        if cellData is KJRandomImage {
            guard let cellData = cellData as? KJRandomImage else { return }
            
            // TODO: refactor setting of image here to use same class as video thumbnails fetcher for CoreSpotlight results
            
            // Image to share (using SDImageCache)
            guard let doodleImageToShare = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(cellData.imageUrl) else { return }
            
            // Init UIActivity
            let favouriteActivity = KJRandomFavouriteActivity(doodle: cellData)
            
            // Init view controller for UIActivity
            let activityVC = UIActivityViewController(activityItems: [ doodleImageToShare ], applicationActivities: [ favouriteActivity ])
            activityVC.excludedActivityTypes = [ UIActivityTypeAddToReadingList ]
            
            // Present UIActivityController
            self.navigationController?.presentViewController(activityVC, animated: true, completion: nil)
            
        } else if cellData is KJComic {
            guard let cellData = cellData as? KJComic else { return }
            guard let comicImageToShare = cellData.returnComicImageFromComic() else { return }
            
            let favouriteActivity = KJComicFavouriteActivity(comic: cellData)
            
            let activityVC = UIActivityViewController(activityItems: [ comicImageToShare ], applicationActivities: [ favouriteActivity ])
            
            activityVC.excludedActivityTypes = [ UIActivityTypeAddToReadingList ]
            
            // Present UIActivityController
            self.navigationController?.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
}