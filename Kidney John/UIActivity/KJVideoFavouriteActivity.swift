//
//  KJVideoFavouriteActivity.swift
//  Kidney John
//
//  Created by Josh Lapham on 15/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import UIKit

class KJVideoFavouriteActivity: UIActivity {
    var titleOfActivity: String
    var videoObject: KJVideo
    
    // MARK: UIActivity
    required init(video: KJVideo) {
        self.videoObject = video
        
        // Init activity title, depending on favourite status of video
        if self.videoObject.isFavourite == false {
            self.titleOfActivity = NSLocalizedString("Add To Favourites", comment: "Title of button to favourite an item")
        } else {
            self.titleOfActivity = NSLocalizedString("Remove From Favourites", comment: "Title of button to remove an item as a favourite")
        }
        
        super.init()
    }
}

extension KJVideoFavouriteActivity {
    // MARK: Methods
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
        
        // Save managedObjectContext
        // TODO: update log messages to use Cocoalumberjack here; or disable completely before App Store release!
        do {
            try self.videoObject.managedObjectContext?.save()
            print("\(__FUNCTION__) - saved managedObjectContext")
            
        } catch let error as NSError {
            print("\(__FUNCTION__) - failed to save managedObjectContext: \(error.debugDescription)")
        }
    }
}