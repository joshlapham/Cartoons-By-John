//
//  DoodleCell.swift
//  Kidney John
//
//  Created by Josh Lapham on 20/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation
import UIKit

class KJDoodleCell: BaseCollectionViewCell_Swift {
    // Properties
    var doodleImageView: UIImageView?
    
    // Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.doodleImageView = UIImageView(frame: self.bounds)
        self.doodleImageView?.contentMode = .ScaleAspectFit
        self.addSubview(self.doodleImageView!)
        
        // Accessibility
        self.setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Helper methods
extension KJDoodleCell {
    override func configureCellWithData(data: AnyObject) {
        guard let cellData = data as? KJRandomImage else { return }
        
        // Set doodle image
        let imageUrl = NSURL(string: cellData.imageUrl)
        self.doodleImageView?.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
    }
}

// MARK: - Accessibility methods
extension KJDoodleCell {
    // Helper method called from `init` method to setup accessibility for this class
    func setupAccessibility() {
        self.isAccessibilityElement = true
        var accessibilityHintString: String?
        
        // Determine which VC presented this cell and return appropriate string
        // VC tags
        let doodlesViewControllerTag = 1001
        let doodlesFavListViewControllerTag = 1002
        
        if self.superview?.tag == doodlesViewControllerTag {
            // Doodles VC
            accessibilityHintString = NSLocalizedString("Swipe left or right to navigate between images", comment: "Accessibility instructions")
        } else if self.superview?.tag == doodlesFavListViewControllerTag {
            // Doodles Favourite List VC
            accessibilityHintString = NSLocalizedString("Tap to view image", comment: "Accessibility instructions")
        } else {
            // NOTE - setting to nil by default (but this shouldn't ever happen)
            accessibilityHintString = nil
        }
        
        self.accessibilityHint = accessibilityHintString
    }
}