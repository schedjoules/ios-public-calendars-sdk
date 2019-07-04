//
//  WeatherCity.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import MapKit

struct WeatherCity: Codable {
    
    let fo: Int
    let la: Double
    let lo: Double
    let to: String
    let ty: String
    
    var annotation: MKAnnotation {
        get {
            let annotation = MKPointAnnotation()
            annotation.title = to
            annotation.coordinate = CLLocationCoordinate2D(latitude: la, longitude: lo)
            return annotation
        }
    }
    var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: la, longitude: lo)
        }
    }
    
}
