//
//  CalendarItemswift
//  iOS-SDK
//
//  Created by Irmak Ozonay on 3.03.2024.
//  Copyright © 2024 SchedJoules. All rights reserved.
//

import Foundation
import UIKit
import SchedJoulesApiClient

class CalendarItemCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursTimeLabel: UILabel!
    @IBOutlet weak var minutesTimeLabel: UILabel!
    @IBOutlet weak var allDayLabel: UILabel!
    @IBOutlet var timeLabels: [UILabel]!
    
    @IBOutlet weak var startTimeAmPmLabel: UILabel!
    @IBOutlet weak var endTimeAmPmLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var amPmWidth: NSLayoutConstraint!
    
    func setContent(event: Event?){
        // Set cell title to the event summary
        titleLabel.text = (event?.summary)!
        
        // Format the time of the event
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        allDayLabel.isHidden = !event!.isAllDay
        timeLabels.forEach({$0.isHidden = event!.isAllDay})
        let startTime = timeFormatter.string(from: event!.startDate)
        let startTimeSplitted = startTime.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "").split(separator: ":").map { String($0) }
        
        if (startTime.contains("AM") || startTime.contains("PM")) {
            startTimeAmPmLabel.text = String(startTime.suffix(2))
        } else {
            amPmWidth.constant = 0
        }
        
        if event!.endDate != nil {
            let endTime = timeFormatter.string(from: event!.endDate!)
            let endTimeSplitted = endTime.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "").split(separator: ":").map { String($0) }
            
            hoursTimeLabel.text = startTimeSplitted[0] + "\n" + endTimeSplitted[0]
            minutesTimeLabel.text = startTimeSplitted[1] + "\n" + endTimeSplitted[1]
            
            hoursTimeLabel.colorString(text: startTimeSplitted[0] + "\n" + endTimeSplitted[0], coloredText: "\n" + endTimeSplitted[0], color: UIColor.gray)
            minutesTimeLabel.colorString(text: startTimeSplitted[1] + "\n" + endTimeSplitted[1], coloredText: "\n" + endTimeSplitted[1], color: UIColor.gray)
            
            if (endTime.contains("AM") || endTime.contains("PM")) {
                endTimeAmPmLabel.text = String(endTime.suffix(2))
            }
        } else {
            hoursTimeLabel.text = startTimeSplitted[0]
            minutesTimeLabel.text = startTimeSplitted[1]
        }
    }
    
}
