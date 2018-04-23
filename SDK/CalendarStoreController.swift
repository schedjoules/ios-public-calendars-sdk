//
//  CalendarStoreController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 20..
//  Copyright © 2018. Balazs Vincze. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SchedJoulesApiClient

public final class CalendarStoreController: UITabBarController {
    /// Colors used by the SDK.
    public struct ColorPalette {
        public static let red = UIColor(red: 241/255.0, green: 102/255.0, blue: 103/255.0, alpha: 1)
    }
    
    /// The API key to be used by the view controllers.
    let apiKey: String
    
    /// The page identifier to be passed to the home page.
    let pageIdentifier: String?
    
    /// The title to be used on the home page's navigation bar.
    let homePageTitle: String?
    
    /// The global tint color used through out the SDK.
    let tintColor: UIColor
    
    /** **For iOS 11.0+**
     Set to false if you don't want to use large navigation bar titles.
    */
    let largeTitle: Bool
    
    // - MARK: Initialization
    
    // This method is only called when initializing a `UIViewController` from a `Storyboard` or `XIB`. The `CalendarStoreController` must only be used programatically, but every subclass of `UIViewController` must implement `init?(coder aDecoder: NSCoder)`.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("CalendarStoreController must only be initialized programatically.")
    }
    
    /**
     - parameter apiKey: The API Key (access token) for the **SchedJoules API**.
     - parameter pageIdentifier: The page identifier for the the home page.
     - parameter title: The title for the `navigtaion bar` in the home page.
     - parameter largeTitle: Set to `false` if you don't want to use large navigation bar titles.
     - parameter tintColor: The tint color used through out the SDK, default is SchedJoules red.
     */
    public init(apiKey: String, pageIdentifier: String?, title: String?, largeTitle: Bool = true, tintColor: UIColor = ColorPalette.red) {
        // Initialization
        self.apiKey = apiKey
        self.pageIdentifier = pageIdentifier
        self.largeTitle = largeTitle
        self.tintColor = tintColor
        homePageTitle = title
        super.init(nibName: nil, bundle: nil)
        
        // Set tab bar tint color
        tabBar.tintColor = tintColor

        // Array to hold the view controllers
        var tabViewControllers = [UIViewController]()
    
        // Create home page with a specific page identifier
        if pageIdentifier != nil {
            let homeVC = PageViewController.init(apiKey: apiKey, pageQuery: SinglePageQuery(pageID: pageIdentifier!, locale: readSettings().last!), searchEnabled: true)
            homeVC.title = title
            tabViewControllers.append(homeVC)
        // Create home page with juts localization parameters
        } else {
            let homeVC = PageViewController(apiKey: apiKey, pageQuery: HomePageQuery(locale: readSettings().first!, location: readSettings().last!), searchEnabled: true)
            homeVC.title = title
            tabViewControllers.append(homeVC)
        }
        
        // Create settings page
        let storyBoard = UIStoryboard.init(name: "SDK", bundle: nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.accessToken = apiKey
        settingsVC.title = "Settings"
        tabViewControllers.append(contentsOf: [homeVC,settingsVC])
        
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
    
    /// Read localization settings, use device defaults otherwise
    func readSettings() -> [String] {
        let languageSetting = UserDefaults.standard.value(forKey: "language_settings") as? Dictionary<String, String>
        let locale = languageSetting != nil ? languageSetting!["countryCode"] : Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        let countrySetting = UserDefaults.standard.value(forKey: "country_settings") as? Dictionary<String, String>
        let location = countrySetting != nil ? countrySetting!["countryCode"] : Locale.current.regionCode
        return [locale!,location!]
    }
    
}
