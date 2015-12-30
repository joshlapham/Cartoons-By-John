//
//  FlushCoreData.swift
//  Kidney John
//
//  Created by Josh Lapham on 31/12/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

/**
`NSOperation` that flushes all videos, comics and doodles locally from Core Data.
*/
class FlushCoreData: Operation {
    private var managedObjectContext: NSManagedObjectContext
    private var managedObjectContextNeedsUpdate: Bool = false
    var videosFlushed: Int?
    var comicsFlushed: Int?
    var doodlesFlushed: Int?
    var flushError: NSError?
    
    func fetchExistingVideosInCoreData() -> [KJVideo]? {
        let entity = NSEntityDescription.entityForName(NSStringFromClass(KJVideo.self) as String, inManagedObjectContext: self.managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        do {
            let existingVideos = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [KJVideo]
            return existingVideos
            
        } catch let error as NSError {
            print("\(__FUNCTION__) - ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchExistingComicsInCoreData() -> [KJComic]? {
        let entity = NSEntityDescription.entityForName(NSStringFromClass(KJComic.self) as String, inManagedObjectContext: self.managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        do {
            let existingComics = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [KJComic]
            return existingComics
            
        } catch let error as NSError {
            print("\(__FUNCTION__) - ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchExistingDoodlesInCoreData() -> [KJRandomImage]? {
        let entity = NSEntityDescription.entityForName(NSStringFromClass(KJRandomImage.self) as String, inManagedObjectContext: self.managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        do {
            let existingDoodles = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [KJRandomImage]
            return existingDoodles
            
        } catch let error as NSError {
            print("\(__FUNCTION__) - ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: NSOperation
    override func execute() {
        if let existingVideos = self.fetchExistingVideosInCoreData() {
            print("Found existing videos in Core Data")
            self.videosFlushed = existingVideos.count
            for video in existingVideos { self.managedObjectContext.deleteObject(video) }
            self.managedObjectContextNeedsUpdate = true
        }
        
        if let existingComics = self.fetchExistingComicsInCoreData() {
            print("Found existing comics in Core Data")
            self.comicsFlushed = existingComics.count
            for comic in existingComics { self.managedObjectContext.deleteObject(comic) }
            self.managedObjectContextNeedsUpdate = true
        }
        
        if let existingDoodles = self.fetchExistingDoodlesInCoreData() {
            print("Found existing doodles in Core Data")
            self.doodlesFlushed = existingDoodles.count
            for doodle in existingDoodles { self.managedObjectContext.deleteObject(doodle) }
            self.managedObjectContextNeedsUpdate = true
        }
        
        if self.managedObjectContextNeedsUpdate == true {
            do {
                try self.managedObjectContext.save()
                print("Finished flushing all data locally from Core Data")
                self.finish()
                
            } catch let error as NSError {
                print("\(__FUNCTION__) - ERROR: \(error.localizedDescription)")
                self.flushError = error
            }
        }
        
        self.cancel()
    }
    
    // MARK: NSObject
    required init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        super.init()
    }
}