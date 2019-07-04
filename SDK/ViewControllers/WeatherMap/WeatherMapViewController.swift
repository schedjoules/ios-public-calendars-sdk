//
//  WeatherMapViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/2/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import MapKit

class WeatherMapViewController: UIViewController {
    
    //Properties
    let locationManager = CLLocationManager()
    var locationDisplayed = false
    
    //UI
    var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupProperties()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupProperties() {
        checkLocationAuthorization()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    

    // MARK: Location
    private func checkLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                mapView.showsUserLocation = true
            case .notDetermined:
                print(locationManager)
                locationManager.requestWhenInUseAuthorization()
                mapView.showsUserLocation = true
            case .denied, .restricted:
                print("show alert")
                break
            }
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    private func startLocationDisplay() {
        let northEastPoint = MKMapPoint(x: mapView.visibleMapRect.maxX,
                                             y: mapView.visibleMapRect.minY)
        let northEastCoordinate = MKCoordinateForMapPoint(northEastPoint)
        
        let southWestPoint = MKMapPoint(x: mapView.visibleMapRect.minX,
                                        y: mapView.visibleMapRect.maxY)
        let southWestCoordinate = MKCoordinateForMapPoint(southWestPoint)
        
        WeatherMapDataSource().getWeatherPoints(northEastCoordinate: northEastCoordinate,
                                                southWestCoordinate: southWestCoordinate) { (cities, error) in
                                                    print(cities)
                                                    print("stop")
                                                    let annotations = cities.map({ $0.annotation })
                                                    self.mapView.delegate = self
                                                    
                                                    DispatchQueue.main.async {
                                                        self.mapView.showAnnotations(annotations, animated: true)
                                                    }
                                                    
        }        
    }
    
    private func presentDetails(_ annotation: MKPointAnnotation) {
        let detailViewController = WeatherDetailViewController(annotation: annotation)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
}

extension WeatherMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        
        presentDetails(annotation)
    }
}


extension WeatherMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: 15.0,
                                                               longitudeDelta: 15.0))
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        
        if locationDisplayed == false {
            locationDisplayed = true
            startLocationDisplay()
        }
    }
    
}
