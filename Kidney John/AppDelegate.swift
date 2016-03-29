//
//  AppDelegate.swift
//  Kidney John
//
//  Created by Josh Lapham on 18/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjackSwift

@UIApplicationMain

class KJAppDelegate: UIResponder {
    var window: UIWindow?
    
    private func setupUI() {
        // Show status bar after app launch image has shown
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        // Navbar colour
        UINavigationBar.appearance().barTintColor = UIColor.kj_navbarColour()
        
        // Shadow for navbar font
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.kj_navbarTitleFontShadowColour()
        shadow.shadowOffset = CGSizeMake(0, 1)
        
        // Navbar title font, colour, shadow, etc
        let titleAttributes = [ NSForegroundColorAttributeName : UIColor.kj_navbarTitleFontColour(), NSShadowAttributeName : shadow, NSFontAttributeName : UIFont.kj_navbarFont() ]
        UINavigationBar.appearance().titleTextAttributes = titleAttributes
        
        // Set navbar items to white
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    private func checkAppVersion() {
        // Initial first app launch
        if NSUserDefaults.kj_hasAppCompletedFirstLaunchSetting() == false {
            NSUserDefaults.kj_setHasAppCompletedFirstLaunchSetting(true)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Version 1.1.2
        self.doVersion112Checks()
    }
    
    // Version 1.1.2
    private func doVersion112Checks() {
        if NSUserDefaults.kj_hasAppCompletedVersion112FirstLaunchSetting() == false {
            // Flush all doodles locally
            // NOTE - only flushing if doodle data fetch has happened
            if NSUserDefaults.kj_hasFirstDoodleFetchCompletedSetting() == true {
                // NOTE - doing this as there was an issue with more than half of all doodle image URLs just prior to version 1.1.2 being submitted to App Store. Image URLs were updated on server side, but there was a bug in the app code which caused older doodle images already existing in Core Data locally not to be updated. Forcing deletion of all local doodle images here as a quick workaround.
                // TODO: revise this after CloudKit refactor
                //                KJDoodleStore.sharedStore().flushLocalDoodlesInContext(self.managedObjectContext)
                
                NSUserDefaults.kj_setHasAppCompletedVersion112FirstLaunchSetting(true)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    // MARK: Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Kidney John", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let persistentStoreOptions = [ NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true ]
        
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("kj.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: persistentStoreOptions)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error as NSError
            
            let wrappedError = NSError(domain: KJAppErrorDomain, code: 9999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            // TODO: fix this
            //            #ifdef DEBUG
            //            abort()
            //            #endif
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                
                // TODO: implement analytics for fatal error to be reported
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                
                // TODO: fix this (only call if in DEBUG)
                //                abort()
            }
        }
    }
}

// MARK: - UIApplicationDelegate
extension KJAppDelegate: UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Do app version checks
        self.checkAppVersion()
        
        // Customize UI
        self.setupUI()
        
        // Init NSNotification observer if dynamic type font size changes.
        // This would be done by the user in Settings.
        // All this does is call setupUI method on App Delegate to re-apply navbar font size.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setupUI"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        // CocoaLumberjack
        // Setup XCode console logger
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        // Init PFConfig
        // TODO: how to handle config with CloudKit?
        //        self.setupPFConfigFromParse()
        
        // Pass NSManagedObjectContext view controllers
        // Videos view
        let tabBarController = self.window?.rootViewController as? KJTabBarController
        let navController = tabBarController?.viewControllers?.first as? UINavigationController
        let initialViewController = navController?.topViewController as? JPLYouTubeListView
        initialViewController?.managedObjectContext = self.managedObjectContext
        
        // Comics view
        let comicsNavController = tabBarController?.viewControllers![1] as? UINavigationController
        let comicListViewController = comicsNavController?.topViewController as? KJComicListView
        comicListViewController?.managedObjectContext = self.managedObjectContext
        
        // Doodles view
        let doodlesNavController = tabBarController?.viewControllers![2] as? UINavigationController
        let doodlesViewController = doodlesNavController?.topViewController as? DoodlesViewController
        doodlesViewController?.managedObjectContext = self.managedObjectContext
        
        // More view
        let moreNavController = tabBarController?.viewControllers![3] as? UINavigationController
        let moreViewController = moreNavController?.topViewController as? KJMoreInitialView
        moreViewController?.managedObjectContext = self.managedObjectContext
        
        // Reachability
        JPLReachabilityManager.sharedManager()
        
        // TESTING - CloudKit
        let queue = NSOperationQueue()
        
//                let flush = FlushCoreData(context: self.managedObjectContext)
//                queue.addOperation(flush)
        
        // Fetch video data
        let videoDataFetch = FetchDataOperation(context: self.managedObjectContext, query: .Video)
        
        videoDataFetch.completionBlock = {
            if videoDataFetch.results.count > 0 {
                let parseData = ParseVideoDataOperation(context: self.managedObjectContext, data: videoDataFetch.results)
                queue.addOperation(parseData)
            }
        }
        
        
        // Fetch comic data
        let comicDataFetch = FetchDataOperation(context: self.managedObjectContext, query: .Comic)
        
        // TODO: update other completion blocks to follow this pattern -- don't check for a results count, just pass to operation
        comicDataFetch.completionBlock = {
            let parseData = ParseComicDataOperation(context: self.managedObjectContext, data: comicDataFetch.results)
            parseData.completionBlock = {
                //                    NSUserDefaults.kj_setHasFirstDoodleFetchCompletedSetting(true)
                //                    print("POSTING NOTIFICATION")
                //                    NSNotificationCenter.defaultCenter().postNotificationName(KJDoodleFetchDidHappenNotification, object: nil)
            }
            queue.addOperation(parseData)
        }
        
        // Fetch doodle data
        let doodleDataFetch = FetchDataOperation(context: self.managedObjectContext, query: .Doodle)
        
        doodleDataFetch.completionBlock = {
            if doodleDataFetch.results.count > 0 {
                let parseData = ParseDoodleDataOperation(context: self.managedObjectContext, data: doodleDataFetch.results)
                parseData.completionBlock = {
                    // TODO: review this
                    NSUserDefaults.kj_setHasFirstDoodleFetchCompletedSetting(true)
                    
                    // TODO: is this notification needed?
                    //                    print("POSTING NOTIFICATION")
                    //                    NSNotificationCenter.defaultCenter().postNotificationName(KJDoodleFetchDidHappenNotification, object: nil)
                }
                queue.addOperation(parseData)
            }
        }
        
        queue.addOperation(videoDataFetch)
        queue.addOperation(comicDataFetch)
        queue.addOperation(doodleDataFetch)
        // END OF TESTING - CloudKit
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        self.saveContext()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
}

// TODO: how to handle this with CloudKit?
// MARK: - PFConfig helper methods
//extension KJAppDelegate {
//    // Struct for PFConfig keys on Parse
//    private struct ParsePFConfigKey {
//        static let UseVersion11Colours = "useVersion11Colours"
//        static let UseSocialLinksFromParse = "useSocialLinksFromParse"
//        static let TrackFavouritedItemEventsWithParseAnalytics = "trackFavouritedItemEventsWithParseAnalytics"
//        static let TrackPlayedVideoEventsWithParseAnalytics = "trackPlayedVideoEventsWithParseAnalytics"
//        static let TrackViewedComicEventsWithParseAnalytics = "trackViewedComicEventsWithParseAnalytics"
//        static let TrackViewedDoodleEventsWithParseAnalytics = "trackViewedDoodleEventsWithParseAnalytics"
//    }
//    
//    // Fetch PFConfig values from Parse and store locally in NSUserDefaults
//    private func setupPFConfigFromParse() {
//        // TODO: update logging statements to use cocoalumberjack
//        
//        // Get PFConfig object in background
//        PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
//            guard let config = config where error == nil else {
//                print("ERROR fetching PFConfig from Parse : \(error?.debugDescription)")
//                return
//            }
//            
//            // SOCIAL MEDIA LINKS
//            // Init should use social links from Parse
//            if let shouldUse = config[ParsePFConfigKey.UseSocialLinksFromParse] as? NSNumber {
//                //                "PFConfig: should use social links from Parse: %@", [shouldUseSocialLinks boolValue] ? @"YES" : @"NO"
//                NSUserDefaults.kj_setShouldUseSocialLinksFromParseSetting(shouldUse.boolValue)
//            }
//            
//            // ANALYTICS
//            // TODO: review this #if statement is working correctly
//            #if TARGET_IPHONE_SIMULATOR
//                
//                // Disable analytics
//                //                DDLogInfo(@"DISABLING all analytics; skipping PFConfig setup for analytics");
//                NSUserDefaults.kj_setShouldTrackFavouritedItemEventsWithParseSetting(false)
//                NSUserDefaults.kj_setShouldTrackPlayedVideoEventsWithParseSetting(false)
//                NSUserDefaults.kj_setShouldTrackViewedComicEventsWithParseSetting(false)
//                NSUserDefaults.kj_setShouldTrackViewedDoodleEventsWithParseSetting(false)
//                
//                #else
//                
//                // Init should track favourited item events with Parse Analytics
//                if let shouldTrack = config[ParsePFConfigKey.TrackFavouritedItemEventsWithParseAnalytics] as? NSNumber {
//                    //                    DDLogInfo(@"PFConfig: should track favourited item events with Parse Analytics: %@", [shouldTrackEventsWithAnalytics boolValue] ? @"YES" : @"NO");
//                    NSUserDefaults.kj_setShouldTrackFavouritedItemEventsWithParseSetting(shouldTrack.boolValue)
//                }
//                
//                // Init should track played video events with Parse Analytics
//                if let shouldTrack = config[ParsePFConfigKey.TrackPlayedVideoEventsWithParseAnalytics] as? NSNumber {
//                    //                        DDLogInfo(@"PFConfig: should track played video events with Parse Analytics: %@", [shouldTrackPlayedVideoEventsWithAnalytics boolValue] ? @"YES" : @"NO");
//                    NSUserDefaults.kj_setShouldTrackPlayedVideoEventsWithParseSetting(shouldTrack.boolValue)
//                }
//                
//                // Init should track viewed comic events with Parse Analytics
//                if let shouldTrack = config[ParsePFConfigKey.TrackViewedComicEventsWithParseAnalytics] as? NSNumber {
//                    //                    DDLogInfo(@"PFConfig: should track viewed comic events with Parse Analytics: %@", [shouldTrackViewedComicEventsWithAnalytics boolValue] ? @"YES" : @"NO");
//                    NSUserDefaults.kj_setShouldTrackViewedComicEventsWithParseSetting(shouldTrack.boolValue)
//                }
//                
//                // Init should track viewed doodle events with Parse Analytics
//                if let shouldTrack = config[ParsePFConfigKey.TrackViewedDoodleEventsWithParseAnalytics] as? NSNumber {
//                    //                    DDLogInfo(@"PFConfig: should track viewed doodle events with Parse Analytics: %@", [shouldTrackViewedDoodleEventsWithAnalytics boolValue] ? @"YES" : @"NO");
//                    NSUserDefaults.kj_setShouldTrackViewedDoodleEventsWithParseSetting(shouldTrack.boolValue)
//                }
//                
//            #endif
//            
//            // Sync NSUserDefaults
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
//    }
//}
