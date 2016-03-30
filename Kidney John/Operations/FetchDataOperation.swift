//
//  FetchDataOperation.swift
//  Kidney John
//
//  Created by jl on 28/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CloudKit
import CoreData
import CocoaLumberjackSwift

enum QueryType {
    case Video
    case Comic
    case Doodle
}

class FetchDataOperation: Operation {
    private var managedObjectContext: NSManagedObjectContext
    private var queryType: QueryType
    private let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    private let videoActivePredicate = NSPredicate(format: "is_visible_in_app == 1")
    private let comicActivePredicate = NSPredicate(format: "is_visible_in_app == 1")
    private let doodleActivePredicate = NSPredicate(format: "is_visible_in_app == 1")
    
    // To be checked in completion handler of this operation
    var results: [CKRecord] = []
    
    // MARK: NSOperation
    override func execute() {
        let query: CKQuery
        
        switch self.queryType {
        case .Video:
            query = CKQuery(recordType: "Video", predicate: videoActivePredicate)
        case .Comic:
            query = CKQuery(recordType: "Comic", predicate: comicActivePredicate)
        case .Doodle:
            query = CKQuery(recordType: "Doodle", predicate: doodleActivePredicate)
        }
        
        DDLogVerbose("CloudKit: fetching ..")
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard error == nil else {
                DDLogError("CloudKit: error - \(error?.localizedDescription)")
                self.cancel()
                return
            }
            
            guard let results = results else {
                DDLogError("CloudKit: could not get results object")
                self.cancel()
                return
            }
            
            self.results = results
            self.finish()
        }
    }
    
    // MARK: NSObject
    required init(context: NSManagedObjectContext, query: QueryType) {
        self.managedObjectContext = context
        self.queryType = query
        super.init()
    }
}
