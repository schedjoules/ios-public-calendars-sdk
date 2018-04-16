//
//  CalendarItemViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 09..
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

class CalendarItemViewController: UIViewController {
    // URL to the .ics file
    var icsURL: URL!
    
    // The parsed events
    var calendar: Calendar?
    
    // The Api Client
    var apiClient: SchedJoulesApi!
    
    // Acitivity indicator reference
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // Load error view
    lazy var loadErrorView = Bundle.main.loadNibNamed("LoadErrorView", owner: self, options: nil)![0] as! LoadErrorView

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subscribeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set subscribe button image
        subscribeButton.setImage(UIImage(named: "Add_White"), for: .normal)
        
        // Remove empty seperators
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Add bottom content inset to avoid content being hidden by subscribe button
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        // Start loading indicator(s)
        setUpActivityIndicator()
        
        // Set subscribe button color
        subscribeButton.backgroundColor = navigationController?.navigationBar.tintColor
        
        // Fetch and parse the ics file
        loadICS()
        
    }
    
    // Fetch and parse the ics file
    func loadICS(){
        apiClient.execute(query: CalendarQuery(url: icsURL), completion: { result in
            switch result {
            case let .success(calendar):
                self.calendar = calendar
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetail" {
            let eventVC = segue.destination as! EventViewController
            let event = sender as! Event
            eventVC.event = event
        }
    }
    
    // Subscribe button pressed
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        let urlBegin = icsURL.absoluteString.range(of: "://")?.upperBound
        let urlString = icsURL.absoluteString[urlBegin!..<icsURL.absoluteString.endIndex]
        let webcal = URL(string: "webcal://\(urlString)")!
        UIApplication.shared.open(webcal, options: [:], completionHandler: nil)
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
        tableView.addSubview(activityIndicator)
        startLoading()
    }
    
    // Show network indicator and activity indicator, also hide subscribe button
    func startLoading(){
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
}


// MARK: - TableView Delegate

extension CalendarItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar?.events.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get event at the row index
        let event = calendar?.events[indexPath.row]
        // Set cell title to the event summary
        cell.textLabel?.text = event?.summary
        
        // Format the time of the event
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        var timeString: String!
        // Set it to "All day" if event is all day
        if event!.isAllDay{
            timeString = "All day"
        } else if event!.endDate != nil {
            timeString = timeFormatter.string(from: event!.startDate) + " - " + timeFormatter.string(from: event!.endDate!)
        } else{
            timeString = timeFormatter.string(from: event!.startDate)
        }
        
        // Make time string bold
        let boldAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: .medium)]
        let boldTimeString = NSMutableAttributedString(string:timeString, attributes:boldAttributes)

        // Format the date of the event
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let sizeAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]
        let dateString = NSMutableAttributedString(string:" " + dateFormatter.string(from: event!.startDate), attributes: sizeAttributes)
        
        // Append the date string to the time
        boldTimeString.append(dateString)
        
        // Set the cell's detail label to the constructed time and date string
        cell.detailTextLabel?.attributedText = boldTimeString
        
        return cell
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

// MARK: - TableView Delegate

extension CalendarItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        // Show the event detail view with the selected event
        let event = calendar?.events[indexPath.row]
        performSegue(withIdentifier: "showEvent", sender: event)
    }
}

// MARK: - Load Error View Delegate
extension CalendarItemViewController: LoadErrorViewDelegate{
    // Reload the ics file
    func refreshPressed() {
        loadICS()
    }
}
