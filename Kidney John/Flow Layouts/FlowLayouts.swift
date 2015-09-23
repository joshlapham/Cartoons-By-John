//
//  FlowLayouts.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

// TODO: testing flow layout toggle

// UICollectionView flow layout for Doodles VC - fullscreen (swipe)
class SwipeFlowLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    // Init method
    convenience init(forCollectionView: UICollectionView?) {
        self.init()
        
        self.scrollDirection = .Horizontal
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 0.0

        if let collectionView = forCollectionView {
            //            print("[SWIPE] CV : \(collectionView.debugDescription)")
            
            // Use up whole screen (or frame)
            self.itemSize = collectionView.bounds.size

            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            collectionView.pagingEnabled = true
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    // NOTE - this crashes
    //    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    //        guard let collectionView = self.collectionView else { return nil }
    //
    //        let attribute = UICollectionViewLayoutAttributes()
    //        //        attribute.frame = collectionView.bounds
    //        attribute.size = collectionView.bounds.size
    //
    //        return attribute
    //    }

    // NOTE - don't think these are affecting anything

    //    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    //        let oldBounds = self.collectionView?.bounds
    //
    //        if CGRectGetWidth(oldBounds!) != CGRectGetWidth(newBounds) {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }

    //    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //        print(rect)
    //        return nil
    //    }
}

// UICollectionView flow layout for Comics List VC - grid
// NOTE - also used on Doodles VC
class GridFlowLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    // Init method
    convenience init(forCollectionView: UICollectionView?) {
        self.init()

        self.scrollDirection = .Vertical
        self.minimumInteritemSpacing = 10.0
        self.minimumLineSpacing = 10.0

        self.itemSize = CGSizeMake(86, 89)

        if let collectionView = forCollectionView {
            //            print("[GRID] CV : \(collectionView.debugDescription)")
            
            // NOTE - these values match the Comic List VC insets (that VC has `automaticallyAdjustsScrollViewInsets` set to `true`; these values allow for that property being set to `false`
            collectionView.contentInset = UIEdgeInsetsMake(84, 20, 69, 20)
            collectionView.pagingEnabled = false
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(86, 89)
    }

    // NOTE - this crashes
    //    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    //        guard let collectionView = self.collectionView else { return nil }
    //
    //        let attribute = UICollectionViewLayoutAttributes()
    //        //        attribute.frame = collectionView.bounds
    //        attribute.size = CGSizeMake(86, 89)
    //
    //        return attribute
    //    }

    // NOTE - don't think these are affecting anything

    //    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    //        let oldBounds = self.collectionView?.bounds
    //
    //        if CGRectGetWidth(oldBounds!) != CGRectGetWidth(newBounds) {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }

    //    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //        print(rect)
    //        return nil
    //    }
}