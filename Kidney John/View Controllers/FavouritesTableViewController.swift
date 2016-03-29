//
//  FavouritesTableViewController.swift
//  Kidney John
//
//  Created by jl on 30/03/2016.
//  Copyright © 2016 Josh Lapham. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

class FavouritesTableViewController: UITableViewController {
    var titleForView: String?
    var cellResults: NSArray?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.titleForView
        
        self.tableView.registerNib(UINib(nibName: KJComicListCell.cellIdentifier(), bundle: nil), forCellReuseIdentifier: KJComicListCell.cellIdentifier())
        self.tableView.registerNib(UINib(nibName: KJVideoCell.cellIdentifier(), bundle: nil), forCellReuseIdentifier: KJVideoCell.cellIdentifier())
        self.tableView.estimatedRowHeight = 122
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Accessibility
        if UIAccessibilityDarkerSystemColorsEnabled() {
            self.view.backgroundColor = UIColor.kj_accessibilityDarkenColoursBackgroundColour()
            
        } else {
            self.view.backgroundColor = UIColor.kj_viewBackgroundColour()
        }
        
        // Check for data source
        if self.cellResults?.count == 0 {
            self.kj_showthereAreNoFavouritesAlertWithTitle(self.titleForView)
        }
    }
}

// MARK: - UITableViewDataSource
extension FavouritesTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellResults?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.cellResults?.firstObject is KJVideo {
            let cell = tableView.dequeueReusableCellWithIdentifier(KJVideoCell.cellIdentifier(), forIndexPath: indexPath) as! KJVideoCell
            
            if let cellData = self.cellResults?.objectAtIndex(indexPath.row) as? KJVideo {
                cell.configureCellWithData(cellData)
            }
            
            return cell
            
        } else if self.cellResults?.firstObject is KJComic {
            let cell = tableView.dequeueReusableCellWithIdentifier(KJComicListCell.cellIdentifier(), forIndexPath: indexPath) as! KJComicListCell
            
            if let cellData = self.cellResults?.objectAtIndex(indexPath.row) as? KJComic {
                cell.configureCellWithData(cellData)
            }
            
            return cell
        }
        
        // Return nil by default
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension FavouritesTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.cellResults?.objectAtIndex(indexPath.row) is KJVideo {
            guard let video = self.cellResults?.objectAtIndex(indexPath.row) as? KJVideo else {
                DDLogError("Could not form video object to pass to Video Detail VC")
                return
            }
            
            let destViewController = VideoDetailViewController()
            destViewController.chosenVideo = video
            
            self.navigationController?.pushViewController(destViewController, animated: true)
            
        } else if self.cellResults?.objectAtIndex(indexPath.row) is KJComic {
            guard let comic = self.cellResults?.objectAtIndex(indexPath.row) as? KJComic else {
                DDLogError("Could not form comic object to pass to Single Image VC")
                return
            }
            
            let storyboard = UIStoryboard(name: "ImageStoryboard", bundle: nil)
            
            guard let destViewController = storyboard.instantiateViewControllerWithIdentifier("SingleImageViewController") as? SingleImageViewController else {
                DDLogError("Could not form dest. VC object to pass comic to")
                return
            }
            
            destViewController.hidesBottomBarWhenPushed = true
            destViewController.imageToShow = comic
            
            self.navigationController?.pushViewController(destViewController, animated: true)
        }
    }
}
