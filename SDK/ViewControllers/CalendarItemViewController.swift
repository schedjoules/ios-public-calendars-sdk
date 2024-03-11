//
//  CalendarItemViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 09..
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

final class CalendarItemViewController: UIViewController {
    
    // - MARK: Public Properties
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    /// The Api client.
    var apiClient: Api!
    
    /// URL to the .ics file.
    var icsURL: URL!
    
    ///The id of the calendar
    var itemId: Int = 0
    
    ///The id of the parent page
    var pageId: Int = 0
    
    var rowCount = 0
    
    // - MARK: Private Properties
    
    /// The parsed events.
    private var calendar: ICalendar?
    private var dateEventMap: [String:[Event]]?
    private var sectionDateTitles: [String]?
    
    // Acitivity indicator reference
    private lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    // Load error view
    private lazy var loadErrorView = Bundle.resourceBundle.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView
    
    // - MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set subscribe button image
        subscribeButton.setImage(UIImage(named: "Add_White", in: Bundle.resourceBundle, compatibleWith: nil), for: .normal)
        
        // Remove empty seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Add bottom content inset to avoid content being hidden by subscribe button
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 100, right: 0)
        
        // Start loading indicator(s)
        setUpActivityIndicator()
        
        // Set subscribe button color
        subscribeButton.backgroundColor = navigationController?.navigationBar.tintColor
        
        // Fetch and parse the ics file
        loadICS()
        
        //Add Share Button
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareTap))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEvent" {
            let eventVC = segue.destination as! EventViewController
            let event = sender as! Event
            eventVC.event = event
        }
    }
    
    // - MARK: Helper Methods
    
    // Fetch and parse the ics file
    func loadICS(){
        apiClient.execute(query: CalendarQuery(url: icsURL), completion: { result in
            switch result {
            case let .success(calendar):
                self.calendar = calendar
                
                AnalyticsTracker.shared().trackScreen(name: self.title, page: nil, url: self.icsURL)
                self.createDateEventMap()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.scrollToNextEvent(in: calendar)
                }

            case .failure:
                DispatchQueue.main.async {
                    self.showLoadErrorView()
                }
            }
            DispatchQueue.main.async {
                self.stopLoading()
            }
        })
    }
    
    func createDateEventMap(){
        if let events = calendar?.events {
            dateEventMap = [:]
            sectionDateTitles = []
            for event in events {
                let dateString = getFormattedDate(startDate: event.startDate)
                if dateEventMap?[dateString] == nil {
                    dateEventMap?[dateString] = []
                    sectionDateTitles?.append(dateString)
                }
                dateEventMap?[dateString]?.append(event)
            }
        }
    }
    
    private func getFormattedDate(startDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: startDate)
    }
    
    //Scroll to the next upcoming Event
    private func scrollToNextEvent(in calendar: ICalendar?) {
        let indexOfUpcomingEvent = calendar?.events.firstIndex(where: { (event) -> Bool in
            let dateForFilter: Date = event.endDate ?? event.startDate
            return Calendar.current.compare(dateForFilter,
                                            to: Date(),
                                            toGranularity: .second) == .orderedDescending
        })
        
        if let sectionDateTitles = sectionDateTitles, let indexOfUpcomingEvent = indexOfUpcomingEvent, let event = calendar?.events[indexOfUpcomingEvent] {
            let sectionOfUpcomingEvent = sectionDateTitles.firstIndex(of: getFormattedDate(startDate: event.startDate)) ?? 0
            let numberOfRows = self.tableView.numberOfRows(inSection: 0)
            if numberOfRows > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: sectionOfUpcomingEvent), at: .top, animated: true)
            }
        }
        
    }
    
    // Subscribe button pressed
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        //Analytics
        let sjCalendar =  SJAnalyticsCalendar(calendarId: itemId,
                                              calendarURL: icsURL)
        let sjEvent = SJAnalyticsObject(calendar: sjCalendar, screenName: self.title)
        NotificationCenter.default.post(name: .SJSubscribeButtonClicked, object: sjEvent)
        
        guard let webcal = icsURL.absoluteString.webcalURL() else {
            return
        }
        
        let freeSubscriptionRecord = FreeSubscriptionRecord()
        
        if StoreManager.shared.isSubscriptionValid == true {
            self.openCalendar(calendarId: self.itemId, url: webcal)
        } else if let appBundle = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String,
                  appBundle == "com.schedjoules.calstore" {
            if freeSubscriptionRecord.canGetFreeCalendar() == true {
                let calendarName = self.title ?? "calendar"
                let freeCalendarAlertController = UIAlertController(title: "First Calendar for Free",
                                                                    message: "Do you want to use your Free Calendar to subscribe to: \(calendarName).",
                                                                    preferredStyle: .alert)
                let acceptAction = UIAlertAction(title: "Ok",
                                                 style: .default) { (_) in
                    self.openCalendar(calendarId: self.itemId, url: webcal)
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
        } else {
            NotificationCenter.default.post(name: .SJLaunchSignUp, object: self)
        }
    }
    
    //Share calendar link
    @objc private func handleShareTap() {
        guard let calendarURL = URL(string: "https://www.schedjoules.com/public-calendars-app-schedjoules/?pageId=\(pageId)&itemId=\(itemId)") else {
            return
        }
        
        let userInfo = ["calendarURL" : calendarURL,
                        "senderVC" : self,
                        "senderButton" : navigationItem.rightBarButtonItem as Any] as [String : Any]
        NotificationCenter.default.post(name: .SJShareCalendar, object: nil, userInfo: userInfo)
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
    
    // Show network indicator and activity indicator, also hide subscribe button
    func startLoading(){
        // Remove the load error view, if present
        if view.subviews.contains(loadErrorView) {
            loadErrorView.removeFromSuperview()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        subscribeButton.isHidden = true
    }
    
    // Hide network indicator and activity indicator, also show subscribe button
    func stopLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
        if calendar?.events.count ?? 0 > 0 {
            subscribeButton.isHidden = false
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
    
    private func openCalendar(calendarId: Int, url: URL) {
        let subscriber = SJDeviceCalendarSubscriber.shared
        subscriber.subscribe(to: calendarId,
                             url: url,
                             screenName: self.title) { (error) in
            if error != nil {
                DispatchQueue.main.async {
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
    }
    
}


// MARK: - TableView Delegate Methods

extension CalendarItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDateTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dateEventMap = dateEventMap {
            return dateEventMap[sectionDateTitles![section]]?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height)
        label.text = sectionDateTitles?[section] ?? ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the table cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CalendarItemCell
        
        // Get event at the row index
        var event: Event?
        if let sectionDateTitles = sectionDateTitles {
            event = dateEventMap?[sectionDateTitles[indexPath.section]]?[indexPath.row]
        }
        
        cell.setContent(event: event)
        cell.colorView.backgroundColor = UIColor.randomColors[rowCount % UIColor.randomColors.count]
        rowCount += 1
        return cell
    }
    
}

// MARK: - TableView Delegate Methods

extension CalendarItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show the event detail view with the selected event
        var event: Event?
        if let sectionDateTitles = sectionDateTitles {
            event = dateEventMap?[sectionDateTitles[indexPath.section]]?[indexPath.row]
        }
        performSegue(withIdentifier: "showEvent", sender: event)
    }
}

// MARK: - Load Error View Delegate Methods

extension CalendarItemViewController: LoadErrorViewDelegate{
    // Reload the ics file
    func refreshPressed() {
        startLoading()
        loadICS()
    }
}
