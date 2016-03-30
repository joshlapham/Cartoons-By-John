//
//  FavouriteDoodlesViewController.swift
//  Kidney John
//
//  Created by jl on 30/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

class FavouriteDoodlesViewController: UICollectionViewController {
    var managedObjectContext: NSManagedObjectContext?
    private var cellResults: [KJRandomImage]?
    private let collectionViewEdgeInset: CGFloat = 20
    private let collectionViewCellWidthHeight: CGFloat = 75
    
    private func setupCollectionView() {
        // Accessibility
        if UIAccessibilityDarkerSystemColorsEnabled() {
            self.collectionView?.backgroundColor = UIColor.kj_accessibilityDarkenColoursBackgroundColour()
            
        } else {
            self.collectionView?.backgroundColor = UIColor.kj_viewBackgroundColour()
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Doodles", comment: "Title of Doodles (drawings) favourites list view")
        
        self.collectionView?.registerClass(KJDoodleCell.self, forCellWithReuseIdentifier: KJDoodleCell.cellIdentifier())
        
        self.setupCollectionView()
        
        if let doodles = self.returnDoodlesFavouriteArray() {
            self.cellResults = doodles
        }
        
        if self.cellResults?.count == 0 {
            self.kj_showthereAreNoFavouritesAlertWithTitle(self.title)
        }
        
        self.collectionView?.reloadData()
    }
    
    func returnDoodlesFavouriteArray() -> [KJRandomImage]? {
        guard let managedObjectContext = self.managedObjectContext else {
            DDLogError("No managed object context object")
            return nil
        }
        
        let entity = NSEntityDescription.entityForName(NSStringFromClass(KJRandomImage.self), inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entity
        let sortBy = NSSortDescriptor(key: "imageId", ascending: true)
        request.sortDescriptors = [ sortBy ]
        
        do {
            let doodles = try managedObjectContext.executeFetchRequest(request) as? [KJRandomImage]
            return doodles
            
        } catch let error as NSError {
            DDLogError("Error fetching favourite Doodles from Core Data : \(error.localizedDescription)")
        }
        
        return nil
    }
}

// MARK: - UICollectionViewDataSource
extension FavouriteDoodlesViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellResults?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(KJDoodleCell.cellIdentifier(), forIndexPath: indexPath) as! KJDoodleCell
        
        if let cellData = self.cellResults?[indexPath.row] {
            cell.configureCellWithData(cellData)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FavouriteDoodlesViewController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let doodle = self.cellResults?[indexPath.row] else {
            DDLogError("No Doodle to pass to Single Image VC")
            return
        }
        
        let storyboard = UIStoryboard(name: "ImageStoryboard", bundle: nil)
        
        guard let destViewController = storyboard.instantiateViewControllerWithIdentifier("SingleImageViewController") as? SingleImageViewController else {
            DDLogError("Could not init Single Image VC from Storyboard")
            return
        }
        
        destViewController.hidesBottomBarWhenPushed = true
        destViewController.imageToShow = doodle
        
        self.navigationController?.pushViewController(destViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavouriteDoodlesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.collectionViewEdgeInset, self.collectionViewEdgeInset, self.collectionViewEdgeInset, self.collectionViewEdgeInset)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionViewCellWidthHeight, self.collectionViewCellWidthHeight)
    }
}
