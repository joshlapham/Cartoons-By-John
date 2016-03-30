//
//  KJVideoFavouriteActivity.swift
//  Kidney John
//
//  Created by Josh Lapham on 15/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import UIKit
import CocoaLumberjackSwift

class KJVideoFavouriteActivity: UIActivity {
    var titleOfActivity: String
    var videoObject: KJVideo
    
    // MARK: UIActivity
    override func activityType() -> String? {
        return "com.joshlapham.Kidney-John favourite video"
    }
    
    override func activityTitle() -> String? {
        return self.titleOfActivity
    }
    
    override func activityImage() -> UIImage? {
        if self.videoObject.isFavourite == false {
            return UIImage(named: "add-to-fav.png")
        } else {
            return UIImage(named: "remove-from-fav.png")
        }
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func activityViewController() -> UIViewController? {
        return nil
    }
    
    override func performActivity() {
        self.activityDidFinish(true)
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // Toggle favourite status for videoObject
        videoObject.isFavourite = !videoObject.isFavourite;
        
        // TODO: add/remove item to/from Spotlight API index
        
        // Track action with Parse analytics (if enabled)
        // TODO: revise this after CloudKit refactor
        //        if NSUserDefaults.kj_shouldTrackFavouritedItemEventsWithParseSetting() == true {
        //            KJParseAnalyticsStore.sharedStore().trackVideoFavouriteEventForVideo(self.videoObject)
        //        }
        
        do {
            try self.videoObject.managedObjectContext?.save()
            DDLogVerbose("Saved managedObjectContext")
            
        } catch let error as NSError {
            DDLogError("Failed to save managedObjectContext : \(error.debugDescription)")
        }
    }
    
    // MARK: NSObject
    required init(video: KJVideo) {
        self.videoObject = video
        
        if self.videoObject.isFavourite == false {
            self.titleOfActivity = NSLocalizedString("Add To Favourites", comment: "Title of button to favourite an item")
        } else {
            self.titleOfActivity = NSLocalizedString("Remove From Favourites", comment: "Title of button to remove an item as a favourite")
        }
        
        super.init()
    }
}
