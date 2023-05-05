//
//  WeatherPointAnnotation.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import MapKit
import SchedJoulesApiClient

class WeatherPointAnnotation: MKPointAnnotation, WeatherAnnotation {
    
    var id: Int
    var latitude: Double
    var longitude: Double
    var name: String
    var group: WeatherAnnotationGroup
    
    override var title: String? {
        get {
            return name
        }
        set {}
    }
    
    override var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {}
    }
    
    
    init(id: Int, latitude: Double, longitude: Double, name: String, group: WeatherAnnotationGroup) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.group = group
        
        super.init()
    }
    
    
    init(annotation: WeatherAnnotation) {
        self.id = annotation.id
        self.latitude = annotation.latitude
        self.longitude = annotation.longitude
        self.name = annotation.name
        self.group = annotation.group
        
        super.init()
    }
    
}
