//
//  WeatherCity.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import MapKit

class WeatherAnnotation: MKPointAnnotation, Codable {
    
    let fo: Int
    let la: Double
    let lo: Double
    let to: String
    let ty: String
    
    override var title: String? {
        get {
            return to
        }
        set {}
    }
    
    override var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: la, longitude: lo)
        }
        set {}
    }
}
