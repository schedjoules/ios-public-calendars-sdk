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
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: Date())
        
        if let day = components.day, day > 0 {
            return "\(day + 1) days"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour + 1) hours"
        } else if let minute = components.minute, minute >= 0 {
            return "\(minute + 1) \((minute + 1) == 1 ? "minute" : "minutes")"
        } else {
            return String()
        }
    }
    
}

