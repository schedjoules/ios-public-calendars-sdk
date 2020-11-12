//
//  AppDelegate.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 01. 24..
//  Copyright © 2018. Balazs Vincze. All rights reserved.
//

import UIKit
import SchedJoulesApiClient
import StoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let iapObserver = StoreManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SKPaymentQueue.default().add(iapObserver)
        
        // Initialize the calendar store
        let calendarVC = CalendarStoreViewController(apiKey: "0443a55244bb2b6224fd48e0416f0d9c", title: "Featured")
        calendarVC.calendarStoreDelegate = self
        calendarVC.view.backgroundColor = .sjBackground
        
        //Add observer to listen for subscribe notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subscribedToCalendar(_:)),
                                               name: .SJSubscribedToCalendar,
                                               object: nil)
        
        // Show the calendar store to either iPhone or iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            window?.rootViewController = calendarVC
            window?.makeKeyAndVisible()
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            //Launch modally to test constrains on iPad
            let launcherVC = UIViewController(nibName: nil, bundle: nil)
            if #available(iOS 13.0, *) {
                launcherVC.view.backgroundColor = .systemBackground
            } else {
                launcherVC.view.backgroundColor = .white
            }
            window?.rootViewController = launcherVC
            window?.makeKeyAndVisible()
            launcherVC.present(calendarVC, animated: true)
        }
        
        return true
    }
    
    @objc private func subscribedToCalendar(_ notification: Notification) {
        
        guard let analyticsEvent = notification.object as? SJAnalyticsObject else {
            fatalError("it's not a Analytics event")
        }
        
        guard let calendarURL = analyticsEvent.calendar?.calendarURL else {
            return
        }
        
        do {
            sjPrint("notification: ", notification)
            let freeSubscriptionRecord = FreeSubscriptionRecord()
            try KeychainPasswordItem(service: freeSubscriptionRecord.serviceName,
                                     account: freeSubscriptionRecord.account).savePassword(calendarURL.absoluteString)
        } catch {
            sjPrint("Register Free Calendar Error: ", error)
        }
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //Check for new subscriptions
        SJDeviceCalendarSubscriber.shared.checkForNewCalendarsInDevice()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(iapObserver)
    }


}


extension AppDelegate: CalendarStoreDelegate {
    
    func calendarStoreDidClose() {
        sjPrint("Delegate did close")
    }
}


//UI Testing
extension AppDelegate {
    
    func resetState() {
        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    }
    
}
