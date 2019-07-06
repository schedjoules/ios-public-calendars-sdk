//
//  WeatherSettings.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

struct WeatherSettings: Codable {
    
    struct Setting: Codable {
        var _default: String
        var title: String
        var options: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case _default = "default"
            case title = "title"
            case options = "options"
        }
    }
    
    var rain: Setting
    var wind: Setting
    var temp: Setting
    var time: Setting
    
}
