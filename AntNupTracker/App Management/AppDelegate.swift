//
// AppDelegate.swift
// AntNupTracker, the ant nuptial flight field database
// Copyright (C) 2020  Abouheif Lab
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import os
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        os_log("Starting up NuptialTracker", log: .default, type: .info)
        
        
        let notificationCenter = UNUserNotificationCenter.current()

        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Record", options: .foreground)
        
        let flightChangeCategory = UNNotificationCategory(identifier: "FLIGHT_CHANGE", actions: [viewAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        notificationCenter.setNotificationCategories([flightChangeCategory])
        notificationCenter.delegate = self
        
        notificationCenter.requestAuthorization(options: .alert, completionHandler: {
        authorised, error in
            DispatchQueue.main.async {
                if (authorised)
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
        
//        UserDefaults.standard.set(false, forKey: "welcomeScreenHasOpened")
       
//        FlightAppManager.shared.sessionManager.clearCredentials()
//        fatalError("Credentials Cleared.")
        
//        FlightAppManager.shared.flights.clearStoredFlight()
//        print("Stored Flights Cleared")
//        fatalError("Stored flights cleared")
        
//        FlightAppManager.shared.sessionManager.initiateLoadAndVerifySessionFromKeychain()
        
//       os_log("Attempting to initialise session from Keychain", log: .default, type: .default)
//        FlightAppManager.shared.loadSessionFromKeychain()
//        fatalError("Got to keychain loading.")
//       os_log("Initialised session from Keychain", log: .default, type: .default)
        FlightAppManager.shared.locationManager.requestWhenInUseAuthorization()
//        os_log("Requesting Location", log: .default, type: .default)
        FlightAppManager.shared.locationManager.delegate = FlightAppManager.shared
        
//        os_log(.debug, "Attempting to initialise Session from keychain")
//        os_log(.debug, "Initialised Session from keychain")
        
        FilteringManager.shared.loadStoredFilters()
        
        FlightAppManager.shared.dateFormatter.dateStyle = .medium
        FlightAppManager.shared.dateFormatter.timeStyle = .short
        FlightAppManager.shared.dateOnlyFormatter.dateStyle = .medium
        FlightAppManager.shared.dateOnlyFormatter.timeStyle = .none
        FlightAppManager.shared.timeFormatter.dateStyle = .none
        FlightAppManager.shared.timeFormatter.timeStyle = .short
        
//        FlightAppManager.shared.jsonDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        FlightAppManager.shared.jsonDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        JSONDecoder.shared.dateDecodingStrategy = .formatted(FlightAppManager.shared.jsonDateFormatter)
        JSONEncoder.shared.dateEncodingStrategy = .formatted(FlightAppManager.shared.jsonDateFormatter)
        
        
        let notification = launchOptions?[.remoteNotification]

        if let notificationContent = notification as? [String: Any?], let flightID = notificationContent["FLIGHT_ID"] as? Int {

//            print("Opened from notification")

            let flightDetailView = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "flightdetail") as! FlightDetailTableViewController

            flightDetailView.flightID = flightID
            
            (window?.rootViewController as! UINavigationController).pushViewController(flightDetailView, animated: true)

        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FlightAppManager.shared.flights.saveFlights()
        FilteringManager.shared.saveFilters()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FlightAppManager.shared.flights.getNewFlights()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        FlightAppManager.shared.flights.saveFlights()
        FilteringManager.shared.saveFilters()
        FlightAppManager.shared.flights.clear()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FlightAppManager.shared.sessionManager.setDeviceToken(deviceToken)
        
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // Code goes here for handling receiving notifications
//    }
//
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Code goes here
        let userInfo = response.notification.request.content.userInfo
        
        // Get the flight ID
        let flightID = userInfo["FLIGHT_ID"] as! Int
        
        if response.actionIdentifier == "VIEW_ACTION" {
            self.loadFlightDetailScreen(for: flightID)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let topViewController: UIViewController = getTopViewController()
        
        let title = notification.request.content.title
        let body = notification.request.content.body
        let alert = UIAlertController(title: title, message: body, preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        
        if notification.request.content.categoryIdentifier == "FLIGHT_CHANGE"{
            
            alert.addAction(.init(title: "View Record", style: .default, handler: { action in
                let flightID = notification.request.content.userInfo["FLIGHT_ID"] as! Int
                
                self.loadFlightDetailScreen(for: flightID)
            }))
        }
        
        FlightAppManager.shared.flights.getNewFlights()
        topViewController.present(alert, animated: true, completion: nil)
    }
    
    func loadFlightDetailScreen(for id:Int){
//        let flightDetailView = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "flightdetail") as! FlightDetailTableViewController
        let flightDetailNavController = UIStoryboard.init(name: "FlightDetail", bundle: .main).instantiateInitialViewController() as! UINavigationController
        
        let flightDetailView = flightDetailNavController.topViewController as! FlightDetailTableViewController

        flightDetailView.flightID = id
        
//        (self.window?.rootViewController as! UINavigationController).pushViewController(flightDetailView, animated: true)
//        let navController = UINavigationController(rootViewController: flightDetailView)
        self.getTopViewController().present(flightDetailNavController, animated: true, completion: nil)
    }
    
    func getTopViewController() -> UIViewController {
        var topViewController: UIViewController = window!.rootViewController!
        
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        
        return topViewController
    }


}

