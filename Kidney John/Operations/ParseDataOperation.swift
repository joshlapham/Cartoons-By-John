//
//  ParseDataOperation.swift
//  Kidney John
//
//  Created by jl on 29/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import CoreData
import CloudKit

class ParseDataOperation: Operation {
    var managedObjectContext: NSManagedObjectContext
    var dataToParse: [CKRecord]
    
    // MARK: NSObject
    required init(context: NSManagedObjectContext, data: [CKRecord]) {
        self.managedObjectContext = context
        self.dataToParse = data
        super.init()
    }
}
