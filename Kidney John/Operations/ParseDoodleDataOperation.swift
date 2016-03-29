//
//  ParseDoodleDataOperation.swift
//  Kidney John
//
//  Created by jl on 29/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CoreData
import CloudKit

// CloudKit keys
private struct DoodleKey {
    static let ImageId = "image_id"
    static let InstagramId = "instagram_id"
    static let Description = "description"
    static let ImageURL = "image_url"
    static let Date = "date"
    static let MatureContent = "is_mature"
}

class ParseDoodleDataOperation: ParseDataOperation {
    private func checkIfExistsInCoreData(imageUrl: String, completion: (KJRandomImage?, NSError?) -> ()) {
        let predicate = NSPredicate(format: "imageUrl == %@", imageUrl)
        let request = NSFetchRequest(entityName: NSStringFromClass(KJRandomImage.self))
        request.predicate = predicate
        
        do {
            let existingDoodles = try self.managedObjectContext.executeFetchRequest(request) as? [KJRandomImage]
            completion(existingDoodles?.first, nil)
            
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func checkIfExistingInCoreDataNeedsUpdate(existingDoodle: KJRandomImage, imageId: String, instagramId: String, description: String, imageUrl: String, date: String) -> Bool {
        let needsUpdate: Bool = existingDoodle.imageId != imageId || existingDoodle.instagramId != instagramId || existingDoodle.imageDescription != description || existingDoodle.imageUrl != imageUrl || existingDoodle.imageDate != date
        return needsUpdate
    }
    
    private func fetchAllExistingInCoreData(completion: ([KJRandomImage]?, NSError?) -> ()) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let request = NSFetchRequest(entityName: NSStringFromClass(KJRandomImage.self))
        request.predicate = predicate
        
        do {
            let existingDoodles = try self.managedObjectContext.executeFetchRequest(request) as? [KJRandomImage]
            completion(existingDoodles, nil)
            
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func deleteRedundant(results: [CKRecord], completion: ([KJRandomImage]?) -> ()) {
        self.fetchAllExistingInCoreData { (existingDoodles: [KJRandomImage]?, error: NSError?) -> () in
            guard error == nil else {
                print("Error fetching all existing doodles in Core Data : \(error?.localizedDescription)")
                return
            }
            
            guard let existingDoodles = existingDoodles else {
                print("Error forming existing doodles object")
                return
            }
            
            var doodlesToDelete: [KJRandomImage]? = []
            let serverResultsImageUrls = results.map({ $0.valueForKey(DoodleKey.ImageURL) as? String })
            
            for doodle in existingDoodles {
                if serverResultsImageUrls.indexOf({ $0 == doodle.imageUrl }) == nil {
                    print("Doodles found in Core Data but not in server results; must no longer be active : \(doodle.imageUrl)")
                    
                    // Mark for deletion from Core Data
                    doodlesToDelete?.append(doodle)
                }
            }
            
            completion(doodlesToDelete)
        }
    }
    
    private func parseDoodleData(results: [CKRecord]) {
        var changesMadeToContext = false
        
        // Delete any existing in Core Data that do not exist in `results` received from server; as they're not set to be visible in-app
        self.deleteRedundant(results) { (doodlesToDelete: [KJRandomImage]?) -> () in
            guard let doodlesToDelete = doodlesToDelete where doodlesToDelete.count > 0 else {
                print("No doodles found in Core Data to delete")
                self.cancel()
                return
            }
            
            for doodle in doodlesToDelete {
                self.managedObjectContext.deleteObject(doodle)
            }
            
            changesMadeToContext = true
        }
        
        for doodle in results {
            let doodleId = doodle.valueForKey(DoodleKey.ImageId) as? String
            let doodleInstagramId = doodle.valueForKey(DoodleKey.InstagramId) as? String
            let doodleDescription = doodle.valueForKey(DoodleKey.Description) as? String
            let doodleDate = doodle.valueForKey(DoodleKey.Date) as? String
            let doodleImageUrl = doodle.valueForKey(DoodleKey.ImageURL) as? String
            
            // TODO: should we be using `imageUrl` or `imageId`?
            if let imageUrl = doodleImageUrl {
                // Check if exists in Core Data
                self.checkIfExistsInCoreData(imageUrl, completion: { (doodle: KJRandomImage?, error: NSError?) -> () in
                    guard error == nil else {
                        print("Error performing check for existing doodle : \(error?.localizedDescription)")
                        self.cancel()
                        return
                    }
                    
                    if let existingDoodle = doodle {
                        print("Doodle exists in Core Data : \(existingDoodle.imageUrl)")
                        
                        // Check if any of its' properties need updating
                        if let instagramId = doodleInstagramId,
                            let description = doodleDescription,
                            let date = doodleDate,
                            let imageUrl = doodleImageUrl,
                            let imageId = doodleId {
                                let needsUpdate = self.checkIfExistingInCoreDataNeedsUpdate(existingDoodle, imageId: imageId, instagramId: instagramId, description: description, imageUrl: imageUrl, date: date)
                                
                                switch needsUpdate {
                                case true :
                                    print("Doodle needs update : \(imageUrl)")
                                    
                                    // TODO: include ID here?
                                    existingDoodle.imageId = imageId
                                    existingDoodle.instagramId = instagramId
                                    existingDoodle.imageDescription = description
                                    existingDoodle.imageUrl = imageUrl
                                    existingDoodle.imageDate = date
                                    
                                    changesMadeToContext = true
                                    
                                case false:
                                    // Doodle exists in Core Data and does not need update; nothing is required
                                    print("Doodle exists but does not require update")
                                }
                                
                        } else {
                            // Could not get all properties required for a doodle object in order to check if it needs update -- just assume nothing needs updating
                        }
                        
                    } else {
                        print("Doodle does not exist in Core Data : \(imageUrl)")
                        
                        // Insert into managed object context
                        let newDoodle = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(KJRandomImage.self),
                            inManagedObjectContext: self.managedObjectContext) as? KJRandomImage
                        
                        newDoodle?.imageId = doodleId
                        newDoodle?.instagramId = doodleInstagramId
                        newDoodle?.imageUrl = doodleImageUrl
                        newDoodle?.imageDescription = doodleDescription
                        newDoodle?.imageDate = doodleDate
                        
                        changesMadeToContext = true
                    }
                })
                
            } else {
                // TODO: handle this -- if we need to?
                fatalError("No image URL! Need to handle this error")
            }
        }
        
        if changesMadeToContext == true {
            print("Changes were made to Core Data, now saving")
            
            // Save managed object context
            do {
                try self.managedObjectContext.save()
                print("Saved managed object context")
                self.finish()
                
            } catch let error as NSError {
                print("Error saving managed object context : \(error.localizedDescription)")
                self.cancel()
            }
            
        } else {
            print("No changes were made to Core Data, no need to save")
            self.finish()
        }
    }
    
    // MARK: NSOperation
    override func execute() {
        self.parseDoodleData(self.dataToParse)
    }
}
