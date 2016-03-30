//
//  VideoDetailViewController.swift
//  Kidney John
//
//  Created by jl on 30/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

class VideoDetailViewController: PBYouTubeVideoViewController {
    var chosenVideo: KJVideo?
    
    func showActivityView() {
        guard let video = self.chosenVideo else {
            DDLogError("No chosen video to share for favourite activity")
            return
        }
        
        let favouriteActivity = VideoFavouriteActivity(video: video)
        
        guard let activityUrl = NSURL(string: "https://www.youtube.com/watch?v=\(video.videoId)") else {
            DDLogError("No URL to share for favourite activity")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [activityUrl], applicationActivities: [favouriteActivity])
        activityVC.excludedActivityTypes = [ UIActivityTypeAddToReadingList ]
        activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        activityVC.popoverPresentationController?.permittedArrowDirections = .Up
        
        self.navigationController?.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.chosenVideo?.videoName
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("showActivityView"))
    }
}
