//
//  BaseCollectionViewCell.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

class BaseCollectionViewCell_Swift: UICollectionViewCell {
    // Cell identifier method
    class func cellIdentifier() -> String! {
        // NOTE - we do it like this (instead of NSStringFromClass) as Swift prepends project name
        return self.description().componentsSeparatedByString(".").last!
    }
    
    // Configure cell with data method
    func configureCellWithData(data: AnyObject) {
        assert(false, "This is an abstract method and should be overridden")
    }
}