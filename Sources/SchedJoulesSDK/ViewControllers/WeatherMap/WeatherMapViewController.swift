//
//  WeatherMapViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/2/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import MapKit
import SchedJoulesApiClient

class WeatherMapViewController: UIViewController {
    
    //Properties
    let locationManager = CLLocationManager()
    var locationDisplayed = false
    let apiClient: Api
    let urlString: String
    let calendarId: Int
    var changedByUser: Bool = false
    
    //UI
    var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    init(apiClient: Api, url: String, calendarId: Int) {
        self.apiClient = apiClient
        self.urlString = url
        self.calendarId = calendarId
        
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
        
        self.mapView.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didMoveMap(gesture:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(didMoveMap(gesture:)))
        zoomGesture.delegate = self
        mapView.addGestureRecognizer(zoomGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didMoveMap(gesture:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @objc func didMoveMap(gesture: UIPanGestureRecognizer) {
        if (gesture.state == .ended) {
            changedByUser = true
        }
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
                locationManager.requestWhenInUseAuthorization()
                mapView.showsUserLocation = true
            case .denied, .restricted:
                startLocationDisplay()
                break
            @unknown default:
                startLocationDisplay()
                break
            }
        } else {
            // Show alert letting the user know they have to turn this on.
            startLocationDisplay()
        }
    }
    
    private func startLocationDisplay() {
        let northEastPoint = MKMapPoint(x: mapView.visibleMapRect.maxX,
                                        y: mapView.visibleMapRect.minY)
        let northEastCoordinate = northEastPoint.coordinate
        
        let southWestPoint = MKMapPoint(x: mapView.visibleMapRect.minX,
                                        y: mapView.visibleMapRect.maxY)
        let southWestCoordinate = southWestPoint.coordinate
        
        let weatherCitiesQuery = WeatherCitiesQuery(northEastCoordinate: northEastCoordinate,
                                                    southWestCoordinate: southWestCoordinate)
        apiClient.execute(query: weatherCitiesQuery) { result in
            switch result {
            case let .success(resultInfo):
                let cities = resultInfo.map({ WeatherPointAnnotation(annotation: $0) })
                
                DispatchQueue.main.async {
                    let allAnnotations = self.mapView.annotations
                    self.mapView.removeAnnotations(allAnnotations)
                    
                    self.mapView.addAnnotations(cities)
                }
                break
            case let .failure(error):
                sjPrint(error.localizedDescription)
                break
            }
        }
    }
    
    private func presentDetails(_ annotation: WeatherPointAnnotation) {
        let detailViewController = WeatherDetailViewController(annotation: annotation,
                                                               apiClient: apiClient,
                                                               url: urlString,
                                                               calendarId: calendarId)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
}

extension WeatherMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is WeatherPointAnnotation else { return nil }
        
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
        guard let annotation = view.annotation as? WeatherPointAnnotation else { return }
        
        presentDetails(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if changedByUser == true {
            changedByUser = false
            startLocationDisplay()
        }
    }
}


extension WeatherMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: 1.0,
                                                               longitudeDelta: 1.0))
        mapView.setRegion(region, animated: false)
        
        locationManager.stopUpdatingLocation()
        
        if locationDisplayed == false {
            locationDisplayed = true
            startLocationDisplay()
        }
    }
    
}


extension WeatherMapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
