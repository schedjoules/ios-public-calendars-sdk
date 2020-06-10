//
//  PageViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 04. 20..
//  Copyright © 2018. SchedJoules. All rights reserved.
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
import SafariServices
import WebKit


class PageViewController<PageQuery: Query>: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,
UISearchBarDelegate, SFSafariViewControllerDelegate, LoadErrorViewDelegate where PageQuery.Result == Page {
    
    // - MARK: Public Properties
    
    /// Reload the view if true.
    public var shouldReload = false
    
    // - MARK: Private Properties
    
    /// The Page query used by this view controller.
    private let pageQuery: PageQuery!
    
    /// The returned Pages object from the query.
    private var page: Page?
    
    /// A temporary variable to hold the Pages object while searching.
    private var tempPage: Page?
    
    /// The Api client.
    private let apiClient: Api
    
    /// The table view for presenting the pages.
    private var tableView: UITableView!
    
    // Acitivity indicator
    private lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // Load error view
    private lazy var loadErrorView = Bundle.resourceBundle.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView
    
    // Search controller
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // Refresh control
    private var refreshControl = UIRefreshControl()
    
    /// If this is true, the search controller is added to the view
    private let isSearchEnabled: Bool
    
    // - MARK: Initialization
    
    /* This method is only called when initializing a `UIViewController` from a `Storyboard` or `XIB`. The `PageViewController`
     must only be used programatically, but every subclass of `UIViewController` must implement `init?(coder aDecoder: NSCoder)`. */
    required init?(coder aDecoder: NSCoder) {
        fatalError("PageViewController must only be initialized programatically.")
    }
    
    /**
     Initialize with a Page query and an Api.
     - parameter apiClient: The API Key (access token) for the **SchedJoules API**.
     - parameter pageQuery: A query with a `Result` of type `Page`.
     - parameter searchEnabled: Set this parameter to true, if you would like to have a search controller present. Default is `false`.
     */
    required init(apiClient: Api, pageQuery: PageQuery, searchEnabled: Bool = false) {
        self.pageQuery = pageQuery
        self.apiClient = apiClient
        self.isSearchEnabled = searchEnabled
        super.init(nibName: nil, bundle: nil)
    }
    
    // - MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the pages from the API
        fetchPages()
        
        // Create a table view
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Set up the activity indicator
        setUpActivityIndicator()
        
        // Remove empty table cell seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Register table cell for reuse
        tableView.register(ItemCollectionViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Set up the refresh control
        refreshControl.tintColor = navigationController?.navigationBar.tintColor
        refreshControl.addTarget(self, action: #selector(fetchPages), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
        // Set up the search controller (if neccessary)
        if isSearchEnabled {
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Refetch the pages if neccessary
        if shouldReload { fetchPages() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // - MARK: Helper Methods
    
    /// Execute the Page query and handle the result.
    @objc private func fetchPages() {
        // Execute the query
        
        apiClient.execute(query: pageQuery, completion: { result in
            switch result {
            case let .success(page):
                // Set the Page variable to the just fecthed Page object
                self.page = page as Page
                AnalyticsTracker.shared().trackScreen(name: self.title,
                                                      page: self.page,
                                                      url: self.pageQuery.url)
                
                // Set the page name as the navigation bar title, only if it has not been explicitly set before
                if self.navigationItem.title == nil {
                    self.navigationItem.title = page.name
                }
            case .failure:
                // Remove the previous pages
                self.page = nil
                
                // Show the loading error view
                self.showErrorView()
            }
            self.tableView.reloadData()
            self.stopLoading()
        })
    }
  
    ///Safaridelegate
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        print("activityItemsFor: ", URL, title)
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
        print("excludedActivityTypesFor: ", URL, title)
        return []
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish: ", controller)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("didCompleteInitialLoad: ", controller)
        print("didCompleteInitialLoad: ", didLoadSuccessfully)
    }
    
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("initialLoadDidRedirectTo: ", controller)
        print("initialLoadDidRedirectTo: ", URL)
    }
    
    //WKWebView delegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("createWebViewWith: ", configuration)
        print("createWebViewWith: ", navigationAction)
        print("createWebViewWith: ", windowFeatures)
        return nil
    }
  
    /// Subscribe to a calendar
    @objc private func subscribe(sender: UIButton){
        let cell = sender.superview as! UITableViewCell
        guard let indexPath = tableView.indexPath(for: cell) else {
            sjPrint("Could not get row")
            return
        }
        
        
        let pageSection = page!.sections[indexPath.section]
        let item = pageSection.items[indexPath.row]
        guard let webcal = item.url.webcalURL() else {
            open(item: item)
            return
        }
        
        //First we check if the user has a valid subscription or if they haven't downloaded the free calendar
        let freeSubscriptionRecord = FreeSubscriptionRecord()
        
        if StoreManager.shared.isSubscriptionValid == true {
            openCalendar(url: webcal)
        } else if freeSubscriptionRecord.canGetFreeCalendar() == true {
            let freeCalendarAlertController = UIAlertController(title: "Firs Calendar for Free",
                                                                message: "Do you want to use your Free Calendar to subscribe to: \(item.name).\n\nYou can't undo this step",
                preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "Ok",
                                             style: .default) { (_) in
                                                self.openCalendar(url: webcal)
            }
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel)
            freeCalendarAlertController.addAction(acceptAction)
            freeCalendarAlertController.addAction(cancelAction)
            present(freeCalendarAlertController, animated: true)
            
            
        } else {
            let storeVC = StoreViewController(apiClient: self.apiClient)
            self.present(storeVC, animated: true, completion: nil)
            return
        }
    }
    
    private func openCalendar(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        NotificationCenter.default.post(name: .subscribedToCalendar, object: url)
    }
  
    /// Set up the activity indicator in the view and start loading
    private func setUpActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = navigationController?.navigationBar.tintColor
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        startLoading()
    }
    
    /// Show network indicator and activity indicator
    private func startLoading(){
        // Remove the load error view, if present
        if view.subviews.contains(loadErrorView) {
            loadErrorView.removeFromSuperview()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    /// Stop all loading indicators and remove error view
    private func stopLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
        tableView.refreshControl?.endRefreshing()
        if tableView.numberOfSections > 0 {
            // Remove the load error view, if present
            if view.subviews.contains(loadErrorView) {
                loadErrorView.removeFromSuperview()
            }
            
            // Add the refresh control
            tableView.refreshControl = refreshControl
            
            // Add the search controller
            if #available(iOS 11.0, *) {
                navigationItem.searchController = searchController
            } else {
                tableView.tableHeaderView = searchController.searchBar
            }
        }
    }
    
    //Open calendar details
    func open(item: PageItem) {
        if item.url.contains("weather") {
            let weatherViewController = WeatherMapViewController(apiClient: apiClient, url: item.url)
            navigationController?.pushViewController(weatherViewController, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "SDK", bundle: Bundle.resourceBundle)
            let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarItemViewController") as! CalendarItemViewController
            calendarVC.icsURL = URL(string: item.url)
            calendarVC.title = item.name
            calendarVC.apiClient = apiClient
            navigationController?.pushViewController(calendarVC, animated: true)
        }
    }
    
    
    /// Show the load error view and hide the refresh control
    private func showErrorView(){
        // Set up the load error view
        loadErrorView.delegate = self
        loadErrorView.refreshButton.setTitleColor(navigationController?.navigationBar.tintColor, for: .normal)
        loadErrorView.refreshButton.layer.borderColor = navigationController?.navigationBar.tintColor.cgColor
        loadErrorView.center = view.center
        view.addSubview(loadErrorView)
        
        // Remove the refresh control
        tableView.refreshControl = nil
        
        // Remove the search controller
        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
        } else {
            tableView.tableHeaderView = nil
        }
    }
    
    // - MARK: Table View Data source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return page?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return page?.sections[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemCollectionViewCell
        cell.delegate = self
        
        // Get the page section
        let pageSection = page?.sections[indexPath.section]
        
        // Get the page item from the given section
        guard let pageItem = pageSection?.items[indexPath.row] else {
            sjPrint("Could not get page item.")
            return cell
        }
      
        cell.setup(pageItem: pageItem,
                   tintColor: navigationController?.navigationBar.tintColor)
        return cell
    }
    
    // Set title for the headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return page?.sections[section].name
    }
    
    // - MARK: Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get page section
        let pageSection = page!.sections[indexPath.section]
        
        // Show the seleced page in a PageViewController
        if pageSection.items[indexPath.row].itemClass == .page {
            let languageSetting = SettingsManager.get(type: .language)
            let singlePageQuery = SinglePageQuery(pageID: String(pageSection.items[indexPath.row].itemID!),
                                                  locale: languageSetting.code)
            let pageVC = PageViewController<SinglePageQuery>(apiClient: apiClient,
                                                             pageQuery: singlePageQuery,
                                                             searchEnabled: true)
            
            navigationController?.pushViewController(pageVC, animated: true)
            // Show the selected calendar
        } else {
            let item = pageSection.items[indexPath.row]
            open(item: item)
        }
    }
    
    // MARK: - Search Delegate Methods
    
    // Store the current page before searching
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tempPage = page
    }
    
    // Perfrom the search
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text from the search bar
        guard let queryText = searchController.searchBar.text else {
            return
        }
        
        // Only search if more than 2 charachters were entered
        if queryText.count > 2 {
            apiClient.execute(query: SearchQuery(query: queryText), completion: { result in
                switch result {
                case let .success(searchPage):
                    self.page = searchPage
                    self.tableView.reloadData()
                case let .failure(error):
                    sjPrint("There was an error searching: \(error)")
                }
            })
        }
    }
    
    // Cancel the search and show the page before searching
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        page = tempPage
        tableView.reloadData()
    }
    
    // MARK: - Load Error View Delegate Methods
    
    func refreshPressed() {
        startLoading()
        fetchPages()
    }
}


extension PageViewController: ItemCollectionViewCellDelegate {

    /// Subscribe to a calendar
    func subscribe(to pageItem: PageItem) {
        guard let webcal = pageItem.url.webcalURL() else {
            open(item: pageItem)
            return
        }
        
        if StoreManager.shared.isSubscriptionValid == true {
            UIApplication.shared.open(webcal, options: [:], completionHandler: nil)
            NotificationCenter.default.post(name: .subscribedToCalendar, object: webcal)
        } else {
            let storeVC = StoreViewController(apiClient: self.apiClient)
            self.present(storeVC, animated: true, completion: nil)
            return
        }
    }
    
}
