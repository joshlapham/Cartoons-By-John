//
//  FetchVideosOperation.swift
//  Kidney John
//
//  Created by jl on 28/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CloudKit
import CoreData

class FetchVideosOperation: NSOperation {
    private var managedObjectContext: NSManagedObjectContext
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    let predicate = NSPredicate(format: "TRUEPREDICATE")

    // MARK: NSObject
    required init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        super.init()
    }

    // MARK: NSOperation
    override func main() {
        super.main()

        let query = CKQuery(recordType: "Video", predicate: predicate)

        print("CloudKit: fetching ..")

        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard error == nil else {
                print("CloudKit: error - \(error?.localizedDescription)")
                return
            }

            guard let results = results else {
                print("CloudKit: could not get results object")
                return
            }

            for video in results {
                let newVideo = NSEntityDescription.insertNewObjectForEntityForName("KJVideo", inManagedObjectContext: self.managedObjectContext) as? KJVideo
                newVideo?.videoName = video.valueForKey("title") as? String
                newVideo?.videoDescription = video.valueForKey("description") as? String
                newVideo?.videoId = video.valueForKey("youtubeId") as? String
                newVideo?.videoDuration = video.valueForKey("duration") as? String
                newVideo?.videoDate = video.valueForKey("date") as? String

                print(newVideo.debugDescription)

                // TODO: save to Core Data? or pass to existing store to handle?
            }
        }
    }
}