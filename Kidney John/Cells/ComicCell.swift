//
//  ComicCell.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation
import UIKit

class KJComicCell: BaseCollectionViewCell_Swift {
    // Properties
    var comicTitle: NSString?
    
    // TODO: review use of optional here
    var comicImageView: UIImageView?
    
    // Methods
    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.comicImageView = UIImageView(frame: self.bounds)
        self.comicImageView?.contentMode = .ScaleToFill;
        self.addSubview(self.comicImageView!)
        
        // Accessibility
        self.setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Helper methods
extension KJComicCell {
    override func configureCellWithData(data: AnyObject) {
        // Init cell data
        if let cellData = data as? KJComic {
            // Set comic title
            self.comicTitle = cellData.comicName
            
            // Set comic thumbnail using SDWebImage
            // TODO: remove SDWebImage eventually
            let filePath = NSURL.fileURLWithPath(cellData.returnThumbnailFilepathForComic())
            self.comicImageView?.sd_setImageWithURL(filePath, placeholderImage: UIImage(named: "placeholder.png"), completed: nil)
        }
    }
}

// MARK: - Accessibility methods
extension KJComicCell {
    // Helper method called from `init` method to setup accessibility for this class
    func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityString = "Comic title: \(self.comicTitle)"
        self.accessibilityLabel = NSLocalizedString(accessibilityString, comment: "Title of comic")
        self.accessibilityHint = NSLocalizedString("Tap to view comic", comment: "Accessibility instructions")
    }
}