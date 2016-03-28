//
//  ParseVideoDataOperation.swift
//  Kidney John
//
//  Created by jl on 28/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CoreData
import CloudKit

class ParseVideoDataOperation: Operation {
    private var managedObjectContext: NSManagedObjectContext
    private var dataToParse: [CKRecord]
    
    // To be checked in completion handler of this operation
    // TODO: do we need to check results if we're inserting into a managed object context anyway?
    var results: [KJVideo?] = []
    
    private func parseVideoData(results: [CKRecord]) {
        for video in results {
            let newVideo = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(KJVideo.self),
                inManagedObjectContext: self.managedObjectContext) as? KJVideo
            
            newVideo?.videoName = video.valueForKey("title") as? String
            newVideo?.videoDescription = video.valueForKey("description") as? String
            newVideo?.videoId = video.valueForKey("youtubeId") as? String
            newVideo?.videoDuration = video.valueForKey("duration") as? String
            newVideo?.videoDate = video.valueForKey("date") as? String
            
            self.results.append(newVideo)
        }
        
        print(self.results.debugDescription)
    }
    
    // MARK: NSOperation
    override func execute() {
        self.parseVideoData(self.dataToParse)
    }
    
    // MARK: NSObject
    required init(context: NSManagedObjectContext, data: [CKRecord]) {
        self.managedObjectContext = context
        self.dataToParse = data
        super.init()
    }
}
