//
//  PagesViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 01. 20..
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
import SDWebImage
import SchedJoulesApiClient
import Alamofire

class PagesViewController: UITableViewController {
    
    // The API Key
    var accessToken: String!
    
    // Reference to the API Client
    var apiClient: SchedJoulesApi!
    
    // The page identifer (optional)
    var pageIdentifier: String?
    
    // The Page object
    private var page: Page?
    
    // Acitivity indicator
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // Load error view
    lazy var loadErrorView = Bundle.main.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView
    
    // Search controller
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    // Should reload
    var shouldReload = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the Api Client
        apiClient = SchedJoulesApi(accessToken: accessToken)

        // Set initial navbar title
        navigationItem.title = title
        
        // If viewcontroller is first in navigation stack
        if self == navigationController?.viewControllers[0] {
            // Set up refresh control
            refreshControl = UIRefreshControl()
            refreshControl?.tintColor = navigationController?.navigationBar.tintColor
            refreshControl?.addTarget(self, action: #selector(generateQuery), for: UIControlEvents.valueChanged)
            
            // Add settings button
            self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(PagesViewController.openSettings))
        }
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = navigationController?.navigationBar.tintColor
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    
        // Remove table view seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Start loading indicator(s)
        setUpActivityIndicator()
        
        // Fetch data to be shown
        generateQuery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Reload the page if needed
        if shouldReload {
            shouldReload = false
            generateQuery()
        }
    }
    
    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return page?.sections.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page?.sections[section].items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get page section
        let pageSection = page?.sections[indexPath.section]
        
        // Get item in section
        guard let item = pageSection?.items[indexPath.row] else {
            print("Could not get item.")
            return cell
        }
        
        // Set text
        cell.textLabel?.text = item.name
        
        // Set icon (if any)
        if item.icon != nil{
            cell.imageView!.sd_setImage(with: item.icon!, placeholderImage: UIImage(named: "Icon_Placeholder"))
        } else {
            cell.imageView!.image = nil
        }
        
        // Add subscribe button if item is a calendar item
        if item.itemClass == .calendar {
            let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            addButton.setImage(UIImage(named: "Add")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.imageView?.tintColor = navigationController?.navigationBar.tintColor
            addButton.addTarget(self, action: #selector(subscribe(sender:)), for: .touchUpInside)
            cell.accessoryView = addButton
            cell.isUserInteractionEnabled = true
            cell.accessoryView?.isUserInteractionEnabled = true
        }
    
        return cell
    }
    
    // Set title for the headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Get page section
        let pageSection = page?.sections[section]
        return pageSection?.name
    }
    
    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get page section
        let pageSection = page!.sections[indexPath.section]
        
        // Show next page in pages hierarchy
        if pageSection.items[indexPath.row].itemClass == .page {
            let storyboard = UIStoryboard(name: "SDK", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "PagesViewController") as! PagesViewController
            nextVC.pageIdentifier = String(pageSection.items[indexPath.row].itemID!)
            nextVC.accessToken = accessToken
            nextVC.title = pageSection.items[indexPath.row].name
            navigationController?.pushViewController(nextVC, animated: true)
        // Show calendar
        } else {
            performSegue(withIdentifier: "showCalendar", sender: pageSection.items[indexPath.row])
        }
    }
    
    // MARK: - Helpers
    
    // Open the settings
    @objc func openSettings() {
        let storyBoard = UIStoryboard.init(name: "SDK", bundle: nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.accessToken = accessToken
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalendar" {
            let calendarVC = segue.destination as! CalendarItemViewController
            let item = sender as! PageItem
            calendarVC.title = item.name
            calendarVC.icsURL = URL(string: item.url)
            calendarVC.apiClient = apiClient
        }
    }
    
    // Subscribe to a calendar
    @objc func subscribe(sender: UIButton){
        let cell = sender.superview as! UITableViewCell
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Could not get row")
            return
        }
        let pageSection = page!.sections[indexPath.section]
        let item = pageSection.items[indexPath.row]
        let urlBegin = item.url.range(of: "://")!.upperBound
        let urlString = item.url[urlBegin..<item.url.endIndex]
        let webcal = URL(string: "webcal://\(urlString)")!
        UIApplication.shared.open(webcal, options: [:], completionHandler: nil)
    }
    
    // Decide which query to use and execute it
    @objc func generateQuery() {
        // Query to fetch specific page by id
        if pageIdentifier != nil {
            // Execute the query
            execute(query: SinglePageQuery(pageID: pageIdentifier!))
        // Else query to fetch localized home page
        } else {
            // Read settings, use device defaults otherwise
            let languageSetting = UserDefaults.standard.value(forKey: "language_settings") as? Dictionary<String, String>
            let locale = languageSetting != nil ? languageSetting!["countryCode"] : Locale.preferredLanguages[0].components(separatedBy: "-")[0]
            let countrySetting = UserDefaults.standard.value(forKey: "country_settings") as? Dictionary<String, String>
            let location = countrySetting != nil ? countrySetting!["countryCode"] : Locale.current.regionCode
            
            // Execute the query
            execute(query: HomePageQuery(locale: locale!, location: location!))
        }
    }
    
    // Execute a query and handle the result
    func execute<T: Query>(query: T) {
        // Turn on network indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Execute the queryf
        apiClient.execute(query: query, completion: { result in
            switch result {
            case let .success(page):
                self.page = page as? Page
            case .failure:
                self.showLoadErrorView()
            }
            self.tableView.reloadData()
            self.stopLoading()
            if self.title == nil {
                self.navigationItem.title = self.page?.name
            }
        })
    }
    
    // MARK: - Loading Indicators
    
    // Show network indicator and activity indicator
    func setUpActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = navigationController?.navigationBar.tintColor
        // Center the activity view
        var center = view.center
        center.y = center.y - (navigationController?.navigationBar.frame.height)!
        activityIndicator.center = center
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
        refreshControl?.endRefreshing()
        if tableView.numberOfSections > 0 {
            loadErrorView.removeFromSuperview()
        }
    }
    
    // Show load error view
    func showLoadErrorView(){
        loadErrorView.delegate = self
        loadErrorView.refreshButton.setTitleColor(navigationController?.navigationBar.tintColor, for: .normal)
        loadErrorView.refreshButton.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        var center = view.center
        center.y = center.y - (navigationController?.navigationBar.frame.height)!
        loadErrorView.center = center
        view.addSubview(loadErrorView)
    }
}

// MARK: - Search Delegate
extension PagesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    // Search
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return
        }
        
        // Only search if more than 2 charachters are entered
        if query.count > 2 {
            apiClient.execute(query: SearchQuery(query: query), completion: { result in
                switch result {
                case let .success(searchPage):
                    self.page = searchPage
                    self.tableView.reloadData()
                case let .failure(error):
                    print("There was an error searching: \(error)")
                }
            })
        }
    }
    
    // Cancel search
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        generateQuery()
    }
}

// MARK: - Load Error View Delegate
extension PagesViewController: LoadErrorViewDelegate{
    func refreshPressed() {
        generateQuery()
    }
}
