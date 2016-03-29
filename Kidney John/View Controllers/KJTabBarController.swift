//
//  KJTabBarController.swift
//  Kidney John
//
//  Created by Josh Lapham on 19/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import Foundation

class KJTabBarController: UITabBarController {
    func setupUI() {
        // Set tab bar background colour
        UITabBar.appearance().barTintColor = UIColor.kj_tabBarBackgroundColour()
        
        // Set tabbar font and colour when button not selected
        let titleAttributesForNormalState = [ NSFontAttributeName : UIFont.kj_tabBarFont(), NSForegroundColorAttributeName : UIColor.kj_tabBarItemFontStateNormalColour() ]
        UITabBarItem.appearance().setTitleTextAttributes(titleAttributesForNormalState, forState: .Normal)
        
        // Set tabbar font and colour when button IS selected
        let titleAttributesForSelectedState = [ NSFontAttributeName : UIFont.kj_tabBarFont(), NSForegroundColorAttributeName : UIColor.kj_tabBarItemFontStateSelectedColour() ]
        UITabBarItem.appearance().setTitleTextAttributes(titleAttributesForSelectedState, forState: .Selected)
        
        // Set colour of button icon when selected
        UITabBar.appearance().tintColor = UIColor.kj_tabBarItemIconStateSelectedColour()
        
        // Set colour of button icons when not selected
        for item in self.tabBar.items! {
            // Use the UIImage category code (KJImageUtils) for the imageWithColor: method
            item.image = item.selectedImage?.imageWithColor(UIColor.kj_tabBarItemIconStateNormalColour()).imageWithRenderingMode(.AlwaysOriginal)
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videos = self.tabBar.items?[0]
        let comics = self.tabBar.items?[1]
        let doodles = self.tabBar.items?[2]
        let more = self.tabBar.items?[3]
        
        videos?.title = NSLocalizedString("Videos", comment: "Title of view")
        comics?.title = NSLocalizedString("Comix", comment: "Title of view")
        doodles?.title = NSLocalizedString("Doodles", comment: "Title of view")
        more?.title = NSLocalizedString("More", comment: "Title of view")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setupUI"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        self.setupUI()
    }
}
