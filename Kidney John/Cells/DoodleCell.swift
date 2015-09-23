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
    
    // TODO: testing flow layout toggle
    //    var collectionView: UICollectionView?
    //    var swipLayout: SwipeFlowLayout?
    //    var gridLayout: GridFlowLayout?
    //    var indexPath: NSIndexPath?
    
    // Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.doodleImageView = UIImageView(frame: self.bounds)
        self.doodleImageView?.contentMode = .ScaleAspectFit
        self.doodleImageView?.userInteractionEnabled = false
        self.addSubview(self.doodleImageView!)
        
        // Accessibility
        self.setupAccessibility()
        
        // TODO: testing flow layout toggle
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didUpdateFlowLayout:"), name: "DoodlesLayoutDidChange", object: nil)
        
        // Auto layout
        //        self.setupConstraints()
        
        // Flow layout
        //        self.determineFlowLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //    override func prepareForReuse() {
    //        // Determine current flow layout on collectionView and re-calculate UI elements if needed
    //        self.determineFlowLayout()
    //    }
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

// TODO: testing flow layout toggle
//// MARK: - Auto layout methods
//extension KJDoodleCell {
//    // Helper method to enable Auto layout for UI elements and apply constraints
//    // TODO: not using this method right now; doesn't seem to play nice with the cell
//    func setupConstraints() {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.doodleImageView?.translatesAutoresizingMaskIntoConstraints = false
//
//        let centerX = NSLayoutConstraint(item: self.doodleImageView!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
//        let centerY = NSLayoutConstraint(item: self.doodleImageView!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
//
//        centerX.identifier = "CENTER-X"
//        centerY.identifier = "CENTER-Y"
//
//        self.addConstraints([ centerX, centerY ])
//    }
//}
//
//// MARK: - Flow layout helper methods
//extension KJDoodleCell {
//    func determineFlowLayout() {
//        guard let collectionView = self.collectionView else { return }
//
//        if collectionView.collectionViewLayout is GridFlowLayout {
//            self.gridLayout = collectionView.collectionViewLayout as? GridFlowLayout
//            self.swipLayout = nil
//
//            self.isGridLayout()
//
//        } else if collectionView.collectionViewLayout is SwipeFlowLayout {
//            self.swipLayout = collectionView.collectionViewLayout as? SwipeFlowLayout
//            self.gridLayout = nil
//
//            self.isSwipeLayout()
//        }
//    }
//
//    func isSwipeLayout() {
//        guard let swipLayout = self.swipLayout else { return }
//        guard let imageView = self.doodleImageView else { return }
//        guard let collectionView = self.collectionView else { return }
//        guard let indexPath = self.indexPath else { return }
//
//        let layoutSize = swipLayout.itemSize
//        let currentSize = self.bounds.size
//        let imageSize = imageView.frame.size
//
//        if currentSize != layoutSize {
//            print("### CELL SIZE DOES NOT MATCH LAYOUT SIZE!")
//
//            // Reload cell
//            // TODO: there always seems to be one or two cells that aren't reloaded properly
//            collectionView.reloadItemsAtIndexPaths( [ indexPath ])
//        }
//
//        if currentSize != imageSize {
//            print("### CELL IMAGE SIZE IS INCORRECT!")
//
//            // Re-calculate imageView frame
//            imageView.frame = self.bounds
//        }
//    }
//
//    func isGridLayout() {
//        guard let gridLayout = self.gridLayout else { return }
//        guard let imageView = self.doodleImageView else { return }
//        guard let collectionView = self.collectionView else { return }
//        guard let indexPath = self.indexPath else { return }
//
//        let layoutSize = gridLayout.itemSize
//        let currentSize = self.bounds.size
//        let imageSize = imageView.frame.size
//
//        if currentSize != layoutSize {
//            print("### CELL SIZE DOES NOT MATCH LAYOUT SIZE!")
//
//            // Reload cell
//            // TODO: there always seems to be one or two cells that aren't reloaded properly
//            collectionView.reloadItemsAtIndexPaths( [ indexPath ])
//        }
//
//        if currentSize != imageSize {
//            print("### CELL IMAGE SIZE IS INCORRECT!")
//
//            // Re-calculate imageView frame
//            imageView.frame = self.bounds
//        }
//    }
//
//    func didUpdateFlowLayout(sender: AnyObject) {
//        self.determineFlowLayout()
//    }
//}