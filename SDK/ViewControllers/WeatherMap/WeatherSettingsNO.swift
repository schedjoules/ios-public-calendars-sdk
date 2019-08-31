//
//  WeatherSettings.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

struct WeatherSettingsNO: Codable {
    
    struct Setting: Codable {
        var _default: String
        var title: String
        var units: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case _default = "default"
            case title = "title"
            case units = "options"
        }
    }
    
    var rain: Setting
    var wind: Setting
    var temp: Setting
    var time: Setting
    
}
