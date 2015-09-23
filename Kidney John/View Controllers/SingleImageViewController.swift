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

class SingleImageViewController: UIViewController {
    // Properties
    var imageToShow: AnyObject?
    @IBOutlet weak private var imageView: UIImageView!
    
    // Methods
    // View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: determine title based on `imageToShow` data type
        self.title = NSLocalizedString("Doodle", comment: "Title of view")
        
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
        guard let imageView = self.imageView else { throw SetImageError.NoImageViewForView }
        
        imageView.contentMode = .ScaleAspectFit
        
        let imageUrl = NSURL(string: image.imageUrl)!
        
        // Set image with SDWebImage
        imageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
    }
}

// MARK: - UIActivityView methods
extension SingleImageViewController {
    func showActivityView() {
        // TODO: should we be returning out of `guard` statements?
        
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
        }
        
        // TODO: allow for Comics to be favourited (or any other data type that might use this VC, based on `imageToShow` property)
    }
}