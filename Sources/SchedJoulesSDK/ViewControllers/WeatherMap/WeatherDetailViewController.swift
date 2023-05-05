//
//  WeatherDetailViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import MapKit
import SchedJoulesApiClient

class WeatherDetailViewController: UIViewController {
    
    //Properties
    private enum Constants {
        static let cellHeight: CGFloat = 60
        static let cellWidth: CGFloat = 88
        static let cellSpace: CGFloat = 10
        
        static let cellIdentifier = "cell"
    }
    
    let weatherPointAnnotation: WeatherPointAnnotation
    var weatherSettings: WeatherSettings?
    var selectedSetting: WeatherSettingsItem?
    let apiClient: Api
    let urlString: String
    let calendarId: Int
    
    
    //UI
    var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    var subscribeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let addImage = UIImage(named: "Add_White", in: Bundle.resourceBundle, compatibleWith: nil)
        button.setImage(addImage, for: .normal)
        button.setTitle(" Subscribe", for: .normal)
        button.backgroundColor = .sjRed
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        return stackView
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    
    init(annotation: WeatherPointAnnotation, apiClient: Api, url: String, calendarId: Int) {
        self.weatherPointAnnotation = annotation
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
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupProperties() {
        let weatherSettingsQuery = WeatherSettingsQuery(locale: SettingsManager.get(type: .language).code,
                                                        location: SettingsManager.get(type: .country).code)
        apiClient.execute(query: weatherSettingsQuery) { result in
            switch result {
            case let .success(resultInfo):
                self.weatherSettings = resultInfo
                self.setup()
                break
            case let .failure(error):
                print(error)
                break
            }
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = .sjGrayLight
        
        view.addSubview(mapView)
        view.addSubview(stackView)
        view.addSubview(subscribeButton)
        
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),
            subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscribeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        mapView.showAnnotations([weatherPointAnnotation], animated: true)
        subscribeButton.addTarget(self, action: #selector(subscribeButtonPressed(_:)), for: .touchUpInside)
    }
    
    func setup() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            guard let weatherSettings = self.weatherSettings else {
                return
            }
            
            let rainLabel = WeatherSettingsView(setting: weatherSettings.rain)
            rainLabel.delegate = self
            self.stackView.addArrangedSubview(rainLabel)
            
            let windLabel = WeatherSettingsView(setting: weatherSettings.wind)
            windLabel.delegate = self
            self.stackView.addArrangedSubview(windLabel)
            
            let temperatureLabel = WeatherSettingsView(setting: weatherSettings.temp)
            temperatureLabel.delegate = self
            self.stackView.addArrangedSubview(temperatureLabel)
            
            let timeLabel = WeatherSettingsView(setting: weatherSettings.time)
            timeLabel.delegate = self
            self.stackView.addArrangedSubview(timeLabel)
            
        }
    }
    
    func dismissOptionsView() {
        //Update the setting with the new data
        guard var newWeatherSettings = self.weatherSettings else {
            return
        }
        
        if let updatedSetting = selectedSetting {
            switch updatedSetting.title {
            case newWeatherSettings.rain.title:
                newWeatherSettings.rain = updatedSetting
            case newWeatherSettings.wind.title:
                newWeatherSettings.wind = updatedSetting
            case newWeatherSettings.temp.title:
                newWeatherSettings.temp = updatedSetting
            case newWeatherSettings.time.title:
                newWeatherSettings.time = updatedSetting
            default:
                break
            }
        }
        
        //Update the view with the new data
        for view in stackView.arrangedSubviews {
            guard let settingsView = view as? WeatherSettingsView else { continue }
            
            if settingsView.setting.title == selectedSetting?.title,
               let updatedSetting = selectedSetting {
                settingsView.update(setting: updatedSetting)
                break
            }
        }
        
        self.weatherSettings = newWeatherSettings
        self.selectedSetting = nil
    }
    
    
    // MARK: Subscription
    
    @objc func subscribeButtonPressed(_ sender: UIButton) {
        //Decompose the url for weather ot use user's settings
        var customUrlString = urlString.replacingOccurrences(of: "{location}", with: "\(weatherPointAnnotation.id)")
        if let weatherSettings = self.weatherSettings {
            customUrlString = customUrlString.replacingOccurrences(of: "{temp}", with: weatherSettings.temp._default)
            customUrlString = customUrlString.replacingOccurrences(of: "{rain}", with: weatherSettings.rain._default)
            customUrlString = customUrlString.replacingOccurrences(of: "{wind}", with: weatherSettings.wind._default)
            customUrlString = customUrlString.replacingOccurrences(of: "{time}", with: weatherSettings.time._default)
        }
        
        guard let webcal = customUrlString.webcalURL() else {
            return
        }
        
        let freeSubscriptionRecord = FreeSubscriptionRecord()
        
        if StoreManager.shared.isSubscriptionValid == true {
            self.openCalendar(calendarId: calendarId, url: webcal)
        } else if let appBundle = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String,
                  appBundle == "com.schedjoules.calstore" {
            if freeSubscriptionRecord.canGetFreeCalendar() == true {
                let calendarName = self.title ?? "calendar"
                let freeCalendarAlertController = UIAlertController(title: "First Calendar for Free",
                                                                    message: "Do you want to use your Free Calendar to subscribe to: \(calendarName).\n\nYou can't undo this step",
                                                                    preferredStyle: .alert)
                let acceptAction = UIAlertAction(title: "Ok",
                                                 style: .default) { (_) in
                    self.openCalendar(calendarId: self.calendarId, url: webcal)
                }
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel)
                freeCalendarAlertController.addAction(acceptAction)
                freeCalendarAlertController.addAction(cancelAction)
                present(freeCalendarAlertController, animated: true)
            } else {
                let storeVC = StoreViewController(apiClient: self.apiClient)
                self.present(storeVC, animated: true, completion: nil)
            }
        } else {
            NotificationCenter.default.post(name: .SJLaunchSignUp, object: self)
        }
    }
    
    private func openCalendar(calendarId: Int, url: URL) {
        let subscriber = SJDeviceCalendarSubscriber.shared
        subscriber.subscribe(to: calendarId,
                             url: url,
                             screenName: self.title) { (error) in
                                if error != nil {
                                    let freeCalendarAlertController = UIAlertController(title: "Error",
                                                                                        message: error?.localizedDescription,
                                                                                        preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "Ok",
                                                                     style: .cancel)
                                    freeCalendarAlertController.addAction(cancelAction)
                                    self.present(freeCalendarAlertController, animated: true)
                                }
        }
    }
    
}

extension WeatherDetailViewController: WeatherSettingsViewDelegate {
    func open(setting: WeatherSettingsItem) {
        selectedSetting = setting
        
        let unitsViewController = WeatherUnitsViewController(setting: setting)
        unitsViewController.delegate = self
        navigationController?.pushViewController(unitsViewController, animated: true)
    }
    
}

extension WeatherDetailViewController: WeatherUnitsDelegate {
    
    func save(updated setting: WeatherSettingsItem) {
        selectedSetting = setting
        dismissOptionsView()
    }
    
}
