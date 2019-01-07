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

final class PageViewController<PageQuery: Query>: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,
                                            UISearchBarDelegate, LoadErrorViewDelegate where PageQuery.Result == Page {
    
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
     Initialize with a Page query and an ApiClient.
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
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        // Set up the activity indicator
        setUpActivityIndicator()
        
        // Remove empty table cell seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Register table cell for reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
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
    
    // - MARK: Helper Methods
    
    /// Execute the Page query and handle the result.
    @objc private func fetchPages() {
        // Execute the query
        apiClient.execute(query: pageQuery, completion: { result in
            switch result {
            case let .success(page):
                // Set the Page variable to the just fecthed Page object
                self.page = page as Page
                
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
    
    /// Subscribe to a calendar
    @objc private func subscribe(sender: UIButton){
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
    
    /// Set up the activity indicator in the view and start loading
    private func setUpActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = navigationController?.navigationBar.tintColor
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get the page section
        let pageSection = page?.sections[indexPath.section]
        
        // Get the page item from the given section
        guard let item = pageSection?.items[indexPath.row] else {
            print("Could not get page item.")
            return cell
        }
        
        // Set text label to the page item's name
        cell.textLabel?.text = item.name
        
        // Set icon (if any)
        if item.icon != nil{
            cell.imageView!.sd_setImage(with: item.icon!, placeholderImage: UIImage(named: "Icon_Placeholder", in: Bundle.resourceBundle,
                                                                                    compatibleWith: nil)
)
        } else {
            cell.imageView!.image = nil
        }
        
        // Add subscribe button if item is a calendar item
        if item.itemClass == .calendar {
            let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            addButton.setImage(UIImage(named: "Add", in: Bundle.resourceBundle,
                                       compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.imageView?.tintColor = navigationController?.navigationBar.tintColor
            addButton.addTarget(self, action: #selector(subscribe(sender:)), for: .touchUpInside)
            cell.accessoryView = addButton
            cell.isUserInteractionEnabled = true
            cell.accessoryView?.isUserInteractionEnabled = true
        // Else add a disclosure indicator
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
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
            let storyboard = UIStoryboard(name: "SDK", bundle: Bundle.resourceBundle)
            let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarItemViewController") as! CalendarItemViewController
            calendarVC.icsURL = URL(string: pageSection.items[indexPath.row].url)
            calendarVC.title = pageSection.items[indexPath.row].name
            calendarVC.apiClient = apiClient
            navigationController?.pushViewController(calendarVC, animated: true)
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
                    print("There was an error searching: \(error)")
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
