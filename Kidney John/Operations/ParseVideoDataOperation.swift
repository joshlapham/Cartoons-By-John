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
    
    private func checkIfExistsInCoreData(videoId: String, completion: (KJVideo?, NSError?) -> ()) {
        let predicate = NSPredicate(format: "videoId == %@", videoId)
        let request = NSFetchRequest(entityName: "KJVideo")
        request.predicate = predicate
        
        do {
            let existingVideos = try self.managedObjectContext.executeFetchRequest(request) as? [KJVideo]
            completion(existingVideos?.first, nil)
            
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func checkIfExistingInCoreDataNeedsUpdate(existingVideo: KJVideo, name: String, description: String, duration: String, date: String) -> Bool {
        let needsUpdate: Bool = existingVideo.videoName != name || existingVideo.videoDescription != description || existingVideo.videoDuration != duration || existingVideo.videoDate != date
        return needsUpdate
    }
    
    private func parseVideoData(results: [CKRecord]) {
        var changesMadeToContext = false
        
        for video in results {
            let videoId = video.valueForKey("youtubeId") as? String
            let videoName = video.valueForKey("title") as? String
            let videoDescription = video.valueForKey("description") as? String
            let videoDuration = video.valueForKey("duration") as? String
            let videoDate = video.valueForKey("date") as? String
            
            // Check if exists in Core Data
            if let videoId = videoId {
                self.checkIfExistsInCoreData(videoId, completion: { (video: KJVideo?, error: NSError?) -> () in
                    guard error == nil else {
                        print("Error performing check for existing video : \(error?.localizedDescription)")
                        return
                    }
                    
                    if let existingVideo = video {
                        print("Video exists in Core Data : \(existingVideo.videoName)")
                        
                        // Check if any of its' properties need updating
                        if let name = videoName,
                            let description = videoDescription,
                            let duration = videoDuration,
                            let date = videoDate {
                                let needsUpdate = self.checkIfExistingInCoreDataNeedsUpdate(existingVideo, name: name, description: description, duration: duration, date: date)
                                
                                switch needsUpdate {
                                case true :
                                    print("Video needs update : \(name)")
                                    
                                    existingVideo.videoName = name
                                    existingVideo.videoDescription = description
                                    existingVideo.videoDuration = duration
                                    existingVideo.videoDate = date
                                    
                                    changesMadeToContext = true
                                    
                                case false:
                                    // Video exists in Core Data and does not need update; nothing is required
                                    print("Video exists but does not require update")
                                }
                                
                        } else {
                            // Could not get all properties required for a video object in order to check if it needs update -- just assume nothing needs updating
                        }
                        
                    } else {
                        print("Video does not exist in Core Data")
                        
                        // Insert into managed object context
                        let newVideo = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(KJVideo.self),
                            inManagedObjectContext: self.managedObjectContext) as? KJVideo
                        
                        newVideo?.videoId = videoId
                        newVideo?.videoName = videoName
                        newVideo?.videoDescription = videoDescription
                        newVideo?.videoDuration = videoDuration
                        newVideo?.videoDate = videoDate
                        
                        changesMadeToContext = true
                    }
                })
                
            } else {
                // TODO: handle this
                fatalError("No video ID! Need to handle this error")
            }
        }
        
        if changesMadeToContext == true {
            print("Changes were made to Core Data, now saving")
            
            // Save managed object context
            do {
                try self.managedObjectContext.save()
                print("Saved managed object context")
                
            } catch let error as NSError {
                print("Error saving managed object context : \(error.localizedDescription)")
            }
            
        } else {
            print("No changes were made to Core Data, no need to save")
        }
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
