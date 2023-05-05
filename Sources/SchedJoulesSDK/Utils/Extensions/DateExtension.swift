//
//  DateExtension.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 6/21/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

extension Date {
    
    func remainingTimeString() -> String {
        //Create the localized calendar to use
        var calendar = Calendar.autoupdatingCurrent
        let languageSetting = SettingsManager.get(type: .language)
        let locale = Locale(identifier: languageSetting.code)
        calendar.locale = locale
        
        //Create the formatter including the calendar so it can be localized based on the app settings
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .full
        dateComponentsFormatter.calendar = calendar
        
        //Create date components to set the units in which the time left will be measured
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: self)
        if let day = components.day, day > 0 {
            dateComponentsFormatter.allowedUnits = .day
        } else if let hour = components.hour, hour > 0 {
            dateComponentsFormatter.allowedUnits = .hour
        } else if let minute = components.minute, minute >= 0 {
            dateComponentsFormatter.allowedUnits = .minute
        } else {
            return String()
        }
        
        //Format the time left
        let time = dateComponentsFormatter.string(from: Date(), to: self)
        return time ?? ""
    }
    
}
