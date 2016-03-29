//
//  ParseComicDataOperation.swift
//  Kidney John
//
//  Created by jl on 29/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CoreData
import CloudKit

// CloudKit keys
private struct ComicKey {
    static let Number = "number"
    static let Title = "title"
    static let Filename = "filename"
    static let MatureContent = "is_mature"
}

class ParseComicDataOperation: ParseDataOperation {
    private func checkIfExistsInCoreData(comicNumber: String, completion: (KJComic?, NSError?) -> ()) {
        let predicate = NSPredicate(format: "comicNumber == %@", comicNumber)
        let request = NSFetchRequest(entityName: NSStringFromClass(KJComic.self))
        request.predicate = predicate
        
        do {
            let existingComics = try self.managedObjectContext.executeFetchRequest(request) as? [KJComic]
            completion(existingComics?.first, nil)
            
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func checkIfExistingInCoreDataNeedsUpdate(existingComic: KJComic, name: String, number: String, filename: String) -> Bool {
        let needsUpdate: Bool = existingComic.comicName != name || existingComic.comicNumber != number || existingComic.comicFileName != filename
        return needsUpdate
    }
    
    private func fetchAllExistingInCoreData(completion: ([KJComic]?, NSError?) -> ()) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let request = NSFetchRequest(entityName: NSStringFromClass(KJComic.self))
        request.predicate = predicate
        
        do {
            let existingComics = try self.managedObjectContext.executeFetchRequest(request) as? [KJComic]
            completion(existingComics, nil)
            
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    private func deleteRedundant(results: [CKRecord], completion: ([KJComic]?) -> ()) {
        self.fetchAllExistingInCoreData { (existingComics: [KJComic]?, error: NSError?) -> () in
            guard error == nil else {
                print("Error fetching all existing comics in Core Data : \(error?.localizedDescription)")
                return
            }
            
            guard let existingComics = existingComics else {
                print("Error forming existing comics object")
                return
            }
            
            var comicsToDelete: [KJComic]? = []
            let serverResultsComicNumbers = results.map({ $0.valueForKey(ComicKey.Number) as? String })
            
            for comic in existingComics {
                if serverResultsComicNumbers.indexOf({ $0 == comic.comicNumber }) == nil {
                    print("Comic found in Core Data but not in server results; must no longer be active : \(comic.comicName)")
                    
                    // Mark for deletion from Core Data
                    comicsToDelete?.append(comic)
                }
            }
            
            completion(comicsToDelete)
        }
    }
    
    private func parseComicData(results: [CKRecord]) {
        print(__FUNCTION__)
        
        var changesMadeToContext = false
        
        // Delete any existing in Core Data that do not exist in `results` received from server; as they're not set to be visible in-app
        self.deleteRedundant(results) { (comicsToDelete: [KJComic]?) -> () in
            guard let comicsToDelete = comicsToDelete where comicsToDelete.count > 0 else {
                print("No comics found in Core Data to delete")
                self.cancel()
                return
            }
            
            for comic in comicsToDelete {
                self.managedObjectContext.deleteObject(comic)
            }
            
            changesMadeToContext = true
        }
        
        for comic in results {
            let comicNumber = comic.valueForKey(ComicKey.Number) as? String
            let comicName = comic.valueForKey(ComicKey.Title) as? String
            let comicFilename = comic.valueForKey(ComicKey.Filename) as? String
            
            if let comicNumber = comicNumber {
                // Check if exists in Core Data
                self.checkIfExistsInCoreData(comicNumber, completion: { (comic: KJComic?, error: NSError?) -> () in
                    guard error == nil else {
                        print("Error performing check for existing comic : \(error?.localizedDescription)")
                        self.cancel()
                        return
                    }
                    
                    if let existingComic = comic {
                        print("Comic exists in Core Data : \(existingComic.comicName)")
                        
                        // Check if any of its' properties need updating
                        if let name = comicName,
                            let filename = comicFilename {
                                let needsUpdate = self.checkIfExistingInCoreDataNeedsUpdate(existingComic, name: name, number: comicNumber, filename: filename)
                                
                                switch needsUpdate {
                                case true :
                                    print("Comic needs update : \(name)")
                                    
                                    existingComic.comicName = name
                                    existingComic.comicNumber = comicNumber
                                    existingComic.comicFileName = filename
                                    
                                    changesMadeToContext = true
                                    
                                case false:
                                    // Video exists in Core Data and does not need update; nothing is required
                                    print("Comic exists but does not require update")
                                }
                                
                        } else {
                            // Could not get all properties required for a video object in order to check if it needs update -- just assume nothing needs updating
                        }
                        
                    } else {
                        print("Comic does not exist in Core Data : \(comicName)")
                        
                        // Insert into managed object context
                        let newComic = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(KJComic.self),
                            inManagedObjectContext: self.managedObjectContext) as? KJComic
                        
                        newComic?.comicNumber = comicNumber
                        newComic?.comicName = comicName
                        newComic?.comicFileName = comicFilename
                        
                        changesMadeToContext = true
                    }
                })
                
            } else {
                // TODO: handle this -- if we need to?
                fatalError("No comic number! Need to handle this error")
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
        print(__FUNCTION__)
        self.parseComicData(self.dataToParse)
    }
}
