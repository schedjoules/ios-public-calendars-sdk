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

class SettingsLocalizationViewController: UIViewController {
    enum DetailType: String {
        case language
        case country
    }
    
    // Table view outlet
    @IBOutlet weak var tableView: UITableView!
    
    // Type of data to show
    var type: DetailType!
    
    // Items
    var items: [Localization] = []
    
    // The API Key
    var accessToken: String!
    
    // Reference to the API Client
    var apiClient: SchedJoulesApi!
    
    // Acitivity indicator reference
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // Load error view
    let loadErrorView = Bundle.main.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView

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
        
    // MARK: - Activity Indicator
    
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
}

// MARK: - Table View Delegate and Data Source
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
        // Save selection to the user defaults
        if indexPath.section == 0 {
            UserDefaults.standard.removeObject(forKey: "\(type.rawValue)_settings")
        } else {
            UserDefaults.standard.set(["displayName":items[indexPath.row].name,"countryCode":items[indexPath.row].code], forKey: "\(type.rawValue)_settings")
        }
        // Move back to the main view controller and refresh
        let mainPageVC = navigationController?.viewControllers.first as! PagesViewController
        mainPageVC.shouldReload = true
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Load Error View Delegate
extension SettingsLocalizationViewController: LoadErrorViewDelegate{
    func refreshPressed() {
        loadItems()
    }
}
