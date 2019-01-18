//
//  CalendarStoreViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 20..
//  Copyright © 2018. Balazs Vincze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import SchedJoulesApiClient

public final class CalendarStoreViewController: UITabBarController {
    /// Colors used by the SDK.
    public struct ColorPalette {
        public static let red = UIColor(red: 241/255.0, green: 102/255.0, blue: 103/255.0, alpha: 1)
    }
    
    /// The ApiClient to be used by the view controllers.
    private let apiClient: Api
    
    /// The page identifier to be passed to the home page.
    private let pageIdentifier: String?
    
    /// The title to be used on the home page's navigation bar.
    private let homePageTitle: String?
    
    /// The global tint color used through out the SDK.
    private let tintColor: UIColor
    
    /** **For iOS 11.0+**
     Set to false if you don't want to use large navigation bar titles.
     */
    private let largeTitle: Bool
    
    /// The Api Key stored on the info.plist
    private var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "SchedJoulesApiKey") as? String else {
            fatalError("No token provided. Add api key ")
        }
        return apiKey
    }()
    
    // - MARK: Initialization
    
    /* This method is only called when initializing a `UIViewController` from a `Storyboard` or `XIB`.
    The `CalendarStoreViewController` must only be used programatically, but every subclass of `UIViewController` must implement
     `init?(coder aDecoder: NSCoder)`. */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("CalendarStoreViewController must only be initialized programatically.")
    }
    
    /**
     - parameter apiKey: The API Key (access token) for the **SchedJoules API**.
     - parameter pageIdentifier: The page identifier for the the home page.
     - parameter title: The title for the `navigtaion bar` in the home page.
     */
    public init(apiKey: String, pageIdentifier: String?, title: String?) {
        // Initialization
        self.apiClient = SchedJoulesApi(accessToken: apiKey)
        self.pageIdentifier = pageIdentifier
        self.largeTitle = true
        self.tintColor = ColorPalette.red
        homePageTitle = title
        super.init(nibName: nil, bundle: nil)
        
        // Set tab bar tint color
        tabBar.tintColor = tintColor
        
        // Add the view controllers to the tab bar controller
        addViewControllers()
        
        AnalyticsTracker.shared().launch(with: apiKey)
    }
    
    /**
     Initialize with an `API key` and a `page identifier` to be used on the home page.
     - parameter apiKey: The API Key (access token) for the **SchedJoules API**.
     - parameter pageIdentifier: The page identifier for the the home page.
     */
    public convenience init(apiKey: String, pageIdentifier: String?) {
        self.init(apiKey: apiKey, pageIdentifier: pageIdentifier, title: nil)
    }
    
    /**
     Initialize with an `API key` and a home page `title`.
     - parameter apiKey: The API Key (access token) for the **SchedJoules API**.
     - parameter title: The title for the `navigtaion bar` in the home page.
     */
    public convenience init(apiKey: String, title: String?) {
        self.init(apiKey: apiKey, pageIdentifier: nil, title: title)
    }
    
    /**
     Initialize with an `API key`.
     - parameter apiKey: The API Key (access token) for the **SchedJoules API**.
     */
    public convenience init(apiKey: String) {
        self.init(apiKey: apiKey, pageIdentifier: nil, title: nil)
    }
    
    // - MARK: Helper Methods
    
    // Add the view controllers to the tab bar controller
    public func addViewControllers () {
        // Array to hold the view controllers
        var tabViewControllers = [UIViewController]()
        
        let languageSetting = SettingsManager.get(type: .language)
        let countrySetting = SettingsManager.get(type: .country)
        
        // Create home page with a specific page identifier
        if pageIdentifier != nil {
            let homeVC = PageViewController(apiClient: apiClient,
                                            pageQuery: SinglePageQuery(pageID: pageIdentifier!, locale: countrySetting.code), searchEnabled: true)
            homeVC.title = homePageTitle
            homeVC.tabBarItem.image = UIImage(named: "Featured", in: Bundle.resourceBundle, compatibleWith: nil)
            tabViewControllers.append(homeVC)
        } else {
            // Create home page with just localization parameters
            let homeVC = PageViewController(apiClient: apiClient,
                                            pageQuery: HomePageQuery(locale: languageSetting.code, location: countrySetting.code), searchEnabled: true)
            homeVC.title = homePageTitle
            homeVC.tabBarItem.image = UIImage(named: "Featured", in: Bundle.resourceBundle, compatibleWith: nil)
            tabViewControllers.append(homeVC)
        }
        
        // Create top page
        let topVC = PageViewController(apiClient: apiClient,
                                       pageQuery: TopPageQuery(numberOfItems: 12, locale: languageSetting.code, location: countrySetting.code))
        topVC.title = "Top"
        topVC.tabBarItem.image = UIImage(named: "Top", in: Bundle.resourceBundle, compatibleWith: nil)
        tabViewControllers.append(topVC)
        
        // Create new page
        let newVC = PageViewController(apiClient: apiClient, pageQuery: NewPageQuery(numberOfItems: 12, locale: languageSetting.code))
        newVC.title = "New"
        newVC.tabBarItem.image = UIImage(named: "New", in: Bundle.resourceBundle, compatibleWith: nil)
        tabViewControllers.append(newVC)
        
        // Create next page
        let nextVC = PageViewController(apiClient: apiClient, pageQuery: NextPageQuery(numberOfItems: 12, locale: languageSetting.code))
        nextVC.title = "Next"
        nextVC.tabBarItem.image = UIImage(named: "Next", in: Bundle.resourceBundle, compatibleWith: nil)
        tabViewControllers.append(nextVC)
        
        // Create settings page
        let storyBoard = UIStoryboard(name: "SDK", bundle: Bundle.resourceBundle)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.apiClient = apiClient
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(named: "Settings", in: Bundle.resourceBundle, compatibleWith: nil)
        tabViewControllers.append(settingsVC)
        
        // Embed all view controllers in a UINavigationController
        viewControllers = tabViewControllers.map {
            let navigationController = UINavigationController(rootViewController: $0)
            navigationController.navigationBar.tintColor = tintColor
            if #available(iOS 11.0, *) {
                navigationController.navigationBar.prefersLargeTitles = largeTitle
            }
            return navigationController
        }
    }
    
}
