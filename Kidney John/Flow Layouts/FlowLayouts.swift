//
//  FlowLayouts.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

// UICollectionView flow layout for Doodles VC - fullscreen (swipe)
class SwipeFlowLayout: UICollectionViewFlowLayout {
    // Init method
    convenience init(forCollectionView: UICollectionView?) {
        self.init()
        
        if let collectionView = forCollectionView {
            self.scrollDirection = .Horizontal
            self.minimumInteritemSpacing = 0.0
            self.minimumLineSpacing = 0.0
            // Use up whole screen (or frame)
            self.itemSize = collectionView.bounds.size
        }
    }
}