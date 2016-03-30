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
    var comicTitle: NSString?
    
    // TODO: review use of optional here
    var comicImageView: UIImageView?
    
    // Accessibility for this class
    func setupAccessibility() {
        self.isAccessibilityElement = true
        let accessibilityString = "Comic title: \(self.comicTitle)"
        self.accessibilityLabel = NSLocalizedString(accessibilityString, comment: "Title of comic")
        self.accessibilityHint = NSLocalizedString("Tap to view comic", comment: "Accessibility instructions")
    }
    
    override func configureCellWithData(data: AnyObject) {
        if let cellData = data as? KJComic {
            self.comicTitle = cellData.comicName
            
            // TODO: remove SDWebImage eventually
            let filePath = NSURL.fileURLWithPath(cellData.returnThumbnailFilepathForComic())
            self.comicImageView?.sd_setImageWithURL(filePath, placeholderImage: UIImage(named: "placeholder.png"), completed: nil)
        }
    }
    
    // MARK: NSObject
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.comicImageView = UIImageView(frame: self.bounds)
        self.comicImageView?.contentMode = .ScaleToFill;
        self.addSubview(self.comicImageView!)
        
        self.setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
