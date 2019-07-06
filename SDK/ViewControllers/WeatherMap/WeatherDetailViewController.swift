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
    
    let weatherAnnotation: WeatherAnnotation
    var weatherSettings: WeatherSettings!
    var selectedSetting: WeatherSettings.Setting?
    let apiClient: Api
    let urlString: String
    
    
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
        button.addTarget(self, action: #selector(subscribeButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        stackView.axis = .vertical
        return stackView
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    var blurredView: UIVisualEffectView = {
        let view = UIVisualEffectView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = UIBlurEffect(style: .regular)
        return view
    }()
    
    var optionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.cellSpace
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.register(WeatherOptionCollectionViewCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionview.backgroundColor = .clear
        return collectionview
    }()
    
    
    init(annotation: WeatherAnnotation, apiClient: Api, url: String) {
        self.weatherAnnotation = annotation
        self.apiClient = apiClient
        self.urlString = url
        
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
        WeatherMapDataService().getWeatherSettings(completion: { (settings, error) in
            guard error == nil,
                let settings = settings else {
                    sjPrint("error loading settings")
                    return
            }
            self.weatherSettings = settings
            self.setup()
        })
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = .sjGrayLight
        
        optionsCollectionView.dataSource = self
        optionsCollectionView.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(stackView)
        view.addSubview(subscribeButton)
        view.addSubview(blurredView)
        view.addSubview(optionsCollectionView)
        
        let optionsLabel = UILabel(frame: .zero)
        optionsLabel.text = "     Options"
        stackView.addArrangedSubview(optionsLabel)
        
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
            
            optionsLabel.heightAnchor.constraint(equalToConstant: 44),
            
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),
            subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscribeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
        
        mapView.showAnnotations([weatherAnnotation], animated: true)
    }
    
    func setup() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            let rainLabel = WeatherSettingsView(setting: self.weatherSettings.rain)
            rainLabel.delegate = self
            self.stackView.addArrangedSubview(rainLabel)
            
            let windLabel = WeatherSettingsView(setting: self.weatherSettings.wind)
            windLabel.delegate = self
            self.stackView.addArrangedSubview(windLabel)
            
            let temperatureLabel = WeatherSettingsView(setting: self.weatherSettings.temp)
            temperatureLabel.delegate = self
            self.stackView.addArrangedSubview(temperatureLabel)
            
            let timeLabel = WeatherSettingsView(setting: self.weatherSettings.time)
            timeLabel.delegate = self
            self.stackView.addArrangedSubview(timeLabel)
            
        }
    }
    
    func presentOptions(_ setting: WeatherSettings.Setting) {
        
        blurredView.center = view.center
        optionsCollectionView.center = view.center
        
        self.optionsCollectionView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.blurredView.frame = self.view.bounds
            self.optionsCollectionView.frame = self.stackView.frame
        }) { (success) in
            self.optionsCollectionView.reloadData()
        }
    }
    
    func dismissOptionsView() {
        //Update the setting with the new data
        if let updatedSetting = selectedSetting {
            switch updatedSetting.title {
            case weatherSettings.rain.title:
                weatherSettings.rain = updatedSetting
            case weatherSettings.wind.title:
                weatherSettings.wind = updatedSetting
            case weatherSettings.temp.title:
                weatherSettings.temp = updatedSetting
            case weatherSettings.time.title:
                weatherSettings.time = updatedSetting
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
        
        self.selectedSetting = nil
        self.optionsCollectionView.reloadData()
        
        //Animate the dismissal of the view
        UIView.animate(withDuration: 0.2, animations: {
            self.blurredView.frame = CGRect(origin: self.view.center, size: .zero)
            self.optionsCollectionView.frame = CGRect(origin: self.view.center, size: CGSize(width: 1, height: 1))
        }) { (success) in
            self.optionsCollectionView.isHidden = true
        }
    }
    
    
    // MARK: Subscription
    
    @objc func subscribeButtonPressed(_ sender: UIButton) {
        //First we check if the user has a valid subscription
        guard StoreManager.shared.isSubscriptionValid == false else {
            let storeVC = StoreViewController(apiClient: self.apiClient)
            self.present(storeVC, animated: true, completion: nil)
            return
        }
        
        //Decompose the url for weather ot use user's settings
        var customUrlString = urlString.replacingOccurrences(of: "{location}", with: "\(weatherAnnotation.fo)")
        customUrlString = customUrlString.replacingOccurrences(of: "{temp}", with: weatherSettings.temp._default)
        customUrlString = customUrlString.replacingOccurrences(of: "{rain}", with: weatherSettings.rain._default)
        customUrlString = customUrlString.replacingOccurrences(of: "{wind}", with: weatherSettings.wind._default)
        customUrlString = customUrlString.replacingOccurrences(of: "{time}", with: weatherSettings.time._default)
        
        guard let webcal = customUrlString.webcalURL() else {
            return
        }
        
        //Open calendar to subscribe
        UIApplication.shared.open(webcal, options: [:], completionHandler: nil)
    }
    
}

extension WeatherDetailViewController: WeatherSettingsViewDelegate {
    
    func open(setting: WeatherSettings.Setting) {
        selectedSetting = setting
        presentOptions(setting)
    }
    
}


extension WeatherDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSetting?.options.keys.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let setting = selectedSetting else {
            return UICollectionViewCell()
        }
        
        let optionKeys = Array(setting.options.keys)
        let optionKey = optionKeys[indexPath.row]
        let option = setting.options[optionKey] ?? ""
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! WeatherOptionCollectionViewCell
        cell.setup(option: option)
        return cell
    }
    
}

extension WeatherDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = selectedSetting else {
            return
        }
        
        let newDefault = Array(setting.options.keys)[indexPath.row]
        selectedSetting?._default = newDefault
        dismissOptionsView()
    }
}


extension WeatherDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellWidth, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let vertical = max(4, (optionsCollectionView.bounds.height - Constants.cellHeight) / 2)
        
        let cellCount = min(2, CGFloat(collectionView.numberOfItems(inSection: section)))
        let horizontal = max(4, (optionsCollectionView.bounds.width - (cellCount * Constants.cellWidth) - ((cellCount - 1) * Constants.cellSpace)) / 2)
        
        return UIEdgeInsetsMake(vertical, horizontal, vertical, horizontal)
    }
}
