//
//  SettingsDetailViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 03. 29..
//  Copyright © 2018. SchedJoules. All rights reserved.
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
import SDWebImage

final class SettingsLocalizationViewController: UIViewController, UINavigationControllerDelegate{
    enum DetailType: String {
        case language
        case country
    }
    
    // - MARK: Public Properties
    
    /// Table view outlet.
    @IBOutlet weak var tableView: UITableView!
    
    /// Type of data to show.
    var type: DetailType!
    
    /// The API Key.
    var accessToken: String!
    
    // - MARK: Private Properties
    
    /// The items in to show.
    private var items: [Localization] = []

    /// The API Client.
    private var apiClient: SchedJoulesApi!
    
    /// Acitivity indicator reference.
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    /// Load error view reference.
    private let loadErrorView = Bundle.main.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView
    
    // - MARK: ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initalize API Client
        apiClient = SchedJoulesApi(accessToken: accessToken)
        
        // Set navbar title
        navigationItem.title = type.rawValue.capitalized
        
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Remove table view seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Start loading indicator(s)
        setUpActivityIndicator()

        // Load the items based on the set type
        loadItems()
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is SettingsViewController {
            // Reference to the CalendarStoreController
            let calendarStoreController = navigationController.parent as! CalendarStoreController
            
            // Readd the view controllers to the tab bar controller to make sure they are using the new settings
            calendarStoreController.addViewControllers()
        }
    }
    
    // MARK: - Helper Methods
    
    // Load the items based on the set type
    func loadItems() {
        switch type {
        case .language:
            // Load the languages
            let languageQuery = LanguageQuery()
            apiClient.execute(query: languageQuery, completion: { result in
                self.stopLoading()
                switch result {
                case let .success(languages):
                    self.items = languages
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure:
                    self.showLoadErrorView()
                }
            })
        default:
            // Load the countries
            let countryQuery = CountryQuery()
            apiClient.execute(query: countryQuery, completion: { result in
                self.stopLoading()
                switch result {
                case let .success(countries):
                    self.items = countries
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure:
                    self.showLoadErrorView()
                }
            })
        }
    }
    
    // Show network indicator and activity indicator
    func setUpActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = navigationController?.navigationBar.tintColor
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        startLoading()
    }
    
    // Show network indicator and activity indicator
    func startLoading(){
        // Remove the load error view, if present
        if view.subviews.contains(loadErrorView) {
            loadErrorView.removeFromSuperview()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    // Hide network indicator and activity indicator
    func stopLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
        if tableView.numberOfSections > 0 {
            loadErrorView.removeFromSuperview()
        }
    }
    
    // Show load error view
    func showLoadErrorView(){
        loadErrorView.delegate = self
        loadErrorView.refreshButton.setTitleColor(navigationController?.navigationBar.tintColor, for: .normal)
        loadErrorView.refreshButton.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        loadErrorView.center = view.center
        view.addSubview(loadErrorView)
    }
    
    /// Read localization settings, use device defaults otherwise
    func readSettings() -> [String] {
        let languageSetting = UserDefaults.standard.value(forKey: "language_settings") as? Dictionary<String, String>
        let locale = languageSetting != nil ? languageSetting!["countryCode"] : Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        let countrySetting = UserDefaults.standard.value(forKey: "country_settings") as? Dictionary<String, String>
        let location = countrySetting != nil ? countrySetting!["countryCode"] : Locale.current.regionCode
        return [locale!,location!]
    }
}

// MARK: - Table View Delegate and Data Source Methods
extension SettingsLocalizationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = "Default"
        } else {
            let item = self.items[indexPath.row]
            cell.textLabel?.text = item.name
            if item.icon != nil {
                cell.imageView?.sd_setImage(with: item.icon, placeholderImage: UIImage(named: "Icon_Placeholder"))
            } else {
                cell.imageView?.image = nil
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the table cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Default was selected
        if indexPath.section == 0 {
            // Remove user settings to revert back to using the device defaults
            UserDefaults.standard.removeObject(forKey: "\(type.rawValue)_settings")
        // Something other than default was selected
        } else {
            // Save selection to the user defaults
            UserDefaults.standard.set(["displayName":items[indexPath.row].name,"countryCode":items[indexPath.row].code], forKey: "\(type.rawValue)_settings")
        }
        
        // Move back to main settings page
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Load Error View Delegate Mehods
extension SettingsLocalizationViewController: LoadErrorViewDelegate{
    func refreshPressed() {
        startLoading()
        loadItems()
    }
}
