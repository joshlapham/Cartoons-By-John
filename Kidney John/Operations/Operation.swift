//
//  Operation.swift
//
//  Created by Josh Lapham on 21/08/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

/*!
NOTE - this code based on NSScreencast.com episode 180 - Advanced NSOperations
http://nsscreencast.com/episodes/180-advanced-nsoperations

Original code -
https://github.com/subdigital/nsscreencast/blob/master/180-advanced-nsoperations/OperationScreencast/OperationScreencast/Operation.swift
*/
class Operation: NSOperation {
    override var asynchronous: Bool {
        return true
    }
    
    private var _executing = false {
        willSet {
            willChangeValueForKey("isExecuting")
        }
        didSet {
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var executing: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValueForKey("isFinished")
        }
        
        didSet {
            didChangeValueForKey("isFinished")
        }
    }
    
    override var finished: Bool {
        return _finished
    }
    
    // MARK: Methods
    override func start() {
        _executing = true
        execute()
    }
    
    // NOTE - this method must be overriden in a subclass
    func execute() {
        fatalError("You must override this")
    }
    
    func finish() {
        _executing = false
        _finished = true
    }
}