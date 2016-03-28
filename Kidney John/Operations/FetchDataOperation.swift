//
//  FetchDataOperation.swift
//  Kidney John
//
//  Created by jl on 28/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CloudKit
import CoreData

enum QueryType {
    case Video
    case Comic
    case Doodle
}

class FetchDataOperation: Operation {
    private var managedObjectContext: NSManagedObjectContext
    private var queryType: QueryType
    private let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    private let predicate = NSPredicate(format: "TRUEPREDICATE")
    
    // To be checked in completion handler of this operation
    var results: [CKRecord] = []
    
    // MARK: NSOperation
    override func execute() {
        let query: CKQuery
        
        switch self.queryType {
        case .Video:
            query = CKQuery(recordType: "Video", predicate: predicate)
        case .Comic:
            query = CKQuery(recordType: "Comic", predicate: predicate)
        case .Doodle:
            query = CKQuery(recordType: "Doodle", predicate: predicate)
        }
        
        print("CloudKit: fetching ..")
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard error == nil else {
                print("CloudKit: error - \(error?.localizedDescription)")
                self.cancel()
                return
            }
            
            guard let results = results else {
                print("CloudKit: could not get results object")
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