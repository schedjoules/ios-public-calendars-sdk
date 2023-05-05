//
//  SettingsDetailViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 03. 29..
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
import SDWebImage

final class SettingsDetailViewController<SettingsQuery: Query>: UIViewController, UITableViewDataSource, UITableViewDelegate,
    LoadErrorViewDelegate where SettingsQuery.Result: Sequence, SettingsQuery.Result.Element: CodedOption {

    // - MARK: Private Properties
    
    /// The table view for presenting the items.
    private var tableView: UITableView!

    /// The query used to load the items that will be shown.
    private let settingsQuery: SettingsQuery

    /// The items to show.
    private var items = [SettingsObject]()

    /// Type of data to show.
    private let settingsType: SettingsManager.SettingsType!

    /// The API Client.
    private let apiClient: Api
    
    /// Reference to the CalendarStoreViewController (used for reloading).
    private var calendarStoreViewController: CalendarStoreViewController?

    /// Acitivity indicator reference.
    private lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    /// Load error view reference.
    private lazy var loadErrorView = Bundle.resourceBundle.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView
    
    // Refresh control
    private var refreshControl = UIRefreshControl()

    /* This method is only called when initializing a `UIViewController` from a `Storyboard` or `XIB`. The `SettingsDetailViewController`
    must only be used programatically, but every subclass of `UIViewController` must implement `init?(coder aDecoder: NSCoder)`. */
    required init?(coder aDecoder: NSCoder) {
        fatalError("SettingsDetailViewController must only be initialized programatically.")
    }

    /**
     Initialize with a query used to load the items which are going to be displayed.
     - parameter settingsQuery: A query with a `Result` of an array of a type that conforms to `CodedOption` protocol.
     */
    required init(apiClient: Api, settingsQuery: SettingsQuery, settingsType: SettingsManager.SettingsType) {
        self.apiClient = apiClient
        self.settingsQuery = settingsQuery
        self.settingsType = settingsType
        super.init(nibName: nil, bundle: nil)
    }

    // - MARK: ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navbar title
        navigationItem.title = settingsType.rawValue.capitalized

        // Create a table view
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        // Remove empty table cell seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Register table cell for reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Start loading indicator(s)
        setUpActivityIndicator()
        
        // Set up the refresh control
        refreshControl.tintColor = navigationController?.navigationBar.tintColor
        refreshControl.addTarget(self, action: #selector(loadItems), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl

        // Load the items with the query passed in on initialization
        loadItems()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if calendarStoreViewController != nil {
            // Re-add the view controllers to the tab bar controller to make sure they are using the new settings
            calendarStoreViewController!.addViewControllers()
        }
    }

    // MARK: - Helper Methods

    // Load the items and refresh the UI
    @objc func loadItems() {
        apiClient.execute(query: settingsQuery, completion: { result in
            self.stopLoading()
            switch result {
            case let .success(loadedItems):
                self.items = loadedItems.map({ SettingsObject(object: $0, type: self.settingsType)})
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            case .failure:
                self.showLoadErrorView()
            }
        })
    }

    // Show network indicator and activity indicator
    func setUpActivityIndicator() {
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
    
    // MARK: - Table View Delegate and Data Source Methods
    
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
                cell.imageView?.sd_setImage(with: item.icon, placeholderImage: UIImage(named: "Icon_Placeholder", in: Bundle.resourceBundle, compatibleWith: nil)
)
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
            SettingsManager.delete(type: settingsType)
        } else {
            // Something other than default was selected
            // Save selection to the user defaults
            let item = items[indexPath.row]
            item.save()
        }
        
        calendarStoreViewController = parent?.parent as? CalendarStoreViewController
        
        // Move back
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Load Error View Delegate Mehods
    
    func refreshPressed() {
        // Refresh the view
        startLoading()
        loadItems()
    }
}
