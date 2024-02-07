//
//  EventViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 10..
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

final class EventViewController: UIViewController {
    
    // - MARK: Public Properties
    
    /// The event to show
    var event: Event!
    
    // IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    
    // - MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set navbar title
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.75, height: 44))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.75, height: 44))
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .black
        label.text = event.summary
        wrapperView.addSubview(label)
        self.navigationItem.titleView = wrapperView
        
//        navigationItem.title = event.summary
//        navigationItem.largeTitleDisplayMode = .never
        
        // Set the colors
        textView.tintColor = navigationController?.navigationBar.tintColor
        timeLabel.textColor = navigationController?.navigationBar.tintColor
        
        // Time formatter
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        if event.isAllDay{
            timeLabel.text = "All Day"
        } else if event.endDate != nil {
            timeLabel.text = timeFormatter.string(from: event.startDate) + " - " + timeFormatter.string(from: event.endDate!)
        } else{
            timeLabel.text = timeFormatter.string(from: event.startDate)
        }
        
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = dateFormatter.string(from: event.startDate)
        
        // Description
        if event.description == ""{
            showNoDescription()
        } else {
            textView.text = event.description
        }
        
        // Location
        if event.location == ""{
            showNoLocation()
        } else {
            locationLabel.text = event.location
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsTracker.shared().trackScreen(name: event.summary, page: nil, url: nil)        
    }
    
    // - MARK: Helper Methods
    
    // Called when there is no description to show
    func showNoDescription(){
        textView.text = "No Description"
        textView.textColor = UIColor.lightGray
        textView.textAlignment = NSTextAlignment.center
    }
    
    // Called when there is no location to show
    func showNoLocation(){
        locationLabel.text = "No Location"
        locationLabel.textColor = UIColor.lightGray
        locationLabel.textAlignment = NSTextAlignment.center
    }

}
