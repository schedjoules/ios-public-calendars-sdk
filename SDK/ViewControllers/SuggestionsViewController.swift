//
//  SuggestionsViewController.swift
//  iOS-SDK
//
//  Created by Alberto on 03/06/22.
//  Copyright © 2022 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient
import SafariServices
import WebKit


class SuggestionsViewController<SuggestionsQuery: Query>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SFSafariViewControllerDelegate, LoadErrorViewDelegate where SuggestionsQuery.Result == Page {
    
    // - MARK: Public Properties
    
    /// Reload the view if true.
    public var shouldReload = false
    
    // - MARK: Private Properties
    
    /// The Page query used by this view controller.
    private let pageQuery: SuggestionsQuery!
    
    /// The returned Pages object from the query.
    private var page: Page?
    
    
    
    private var deeplinkItemId: Int?
    
    
    /// A temporary variable to hold the Pages object while searching.
    private var tempPage: Page?
    
    /// The Api client.
    private let apiClient: Api
    
    /// The table view for presenting the pages.
    private var tableView: UICollectionView!
    
    // - MARK: Initialization
    
    /* This method is only called when initializing a `UIViewController` from a `Storyboard` or `XIB`. The `SuggestionsViewController`
     must only be used programatically, but every subclass of `UIViewController` must implement `init?(coder aDecoder: NSCoder)`. */
    required init?(coder aDecoder: NSCoder) {
        fatalError("SuggestionsViewController must only be initialized programatically.")
    }
    
    /**
     Initialize with a Page query and an Api.
     - parameter apiClient: The API Key (access token) for the **SchedJoules API**.
     - parameter pageQuery: A query with a `Result` of type `Page`.
     - parameter searchEnabled: Set this parameter to true, if you would like to have a search controller present. Default is `false`.
     */
    required init(apiClient: Api, pageQuery: SuggestionsQuery, searchEnabled: Bool = false, deeplinkItemId: Int? = 0) {
        self.pageQuery = pageQuery
        self.apiClient = apiClient
        self.deeplinkItemId = deeplinkItemId
        
        super.init(nibName: nil, bundle: nil)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green//.sjBackground
    }
    
    // - MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the pages from the API
        fetchPages()
        
        // Create a table view
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        
        tableView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Register table cell for reuse
        tableView.register(SuggestionsCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
                
                self.navigationItem.title = page.name
                
                if self.deeplinkItemId != 0 {
                    page.sections.forEach { pageSection in
                        if let matchingItem = pageSection.items.filter({ $0.itemID == self.deeplinkItemId }).first {
                            self.open(item: matchingItem)
                            return
                        }
                    }
                }
                self.navigationItem.title = page.name
            case .failure:
                // Remove the previous pages
                self.page = nil
            }
            self.tableView.reloadData()
        })
    }
    
    ///Safaridelegate
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
        return []
    }
    
    //WKWebView delegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
    
    private func openCalendar(calendarId: Int, url: URL) {
        let subscriber = SJDeviceCalendarSubscriber.shared
        subscriber.subscribe(to: calendarId,
                             url: url,
                             screenName: self.title) { (error) in
                                if error == nil {
                                    let freeCalendarAlertController = UIAlertController(title: "Error",
                                                                                        message: error?.localizedDescription,
                                                                                        preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "Ok",
                                                                     style: .cancel)
                                    freeCalendarAlertController.addAction(cancelAction)
                                    self.present(freeCalendarAlertController, animated: true)
                                }
        }
    }
    
    //Open calendar details
    func open(item: PageItem) {
        if item.url.contains("weather") {
            let weatherViewController = WeatherMapViewController(apiClient: apiClient, url: item.url, calendarId: item.itemID ?? 0)
            navigationController?.pushViewController(weatherViewController, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "SDK", bundle: Bundle.resourceBundle)
            let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarItemViewController") as! CalendarItemViewController
            calendarVC.icsURL = URL(string: item.url)
            calendarVC.title = item.name
            calendarVC.apiClient = apiClient
            calendarVC.itemId = item.itemID ?? 0
            calendarVC.pageId = page?.itemID ?? 0
            navigationController?.pushViewController(calendarVC, animated: true)
        }
    }
    
    
    // - MARK: UICollectionView View Data source Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let page = self.page,
              let firstSection = page.sections.first else {
            return 0
        }
        return firstSection.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SuggestionsCollectionViewCell
        
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
        return "page?.sections[section].name"
    }
    
    // - MARK: Table View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView.deselectItem(at: indexPath, animated: true)
        
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
    
    // MARK: - Load Error View Delegate Methods
    
    func refreshPressed() {
        fetchPages()
    }
}
