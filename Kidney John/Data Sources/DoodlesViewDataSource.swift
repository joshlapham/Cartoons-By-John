//
//  DoodlesViewDataSource.swift
//  Kidney John
//
//  Created by jl on 29/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import Foundation

class DoodlesViewDataSource: NSObject {
    var cellDataSource: [KJRandomImage]?
}

// MARK: - UICollectionViewDataSource
extension DoodlesViewDataSource: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellDataSource?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(KJDoodleCell.cellIdentifier(), forIndexPath: indexPath) as! KJDoodleCell
        
        if let cellData = self.cellDataSource?[indexPath.row] {
            cell.configureCellWithData(cellData)
        }
        
        return cell
    }
}
