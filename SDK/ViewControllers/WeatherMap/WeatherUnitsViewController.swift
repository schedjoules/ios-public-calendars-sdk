//
//  WeatherUnitsViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 8/5/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient

protocol WeatherUnitsDelegate: class {
    func save(updated setting: WeatherSettingsItem)
}

class WeatherUnitsViewController: UIViewController {
    
    //Properties
    weak var delegate: WeatherUnitsDelegate?
    
    private enum Constants {
        static let cellHeight: CGFloat = 44
        static let cellSpace: CGFloat = 16
        
        static let cellIdentifier = "cell"
    }
    
    var setting: WeatherSettingsItem
    
    //UI
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.cellSpace
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.register(WeatherUnitCollectionViewCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionview.backgroundColor = .clear
        return collectionview
    }()
    
    
    init(setting: WeatherSettingsItem) {
        self.setting = setting
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupProperties() {
    }
    
    private func setupUI() {
        view.backgroundColor = .sjGrayLight
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.cellHeight),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }

}


extension WeatherUnitsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setting.units.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let unitKeys = Array(setting.units.keys)
        let unitKey = unitKeys[indexPath.row]
        let unit = setting.units[unitKey] ?? ""

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! WeatherUnitCollectionViewCell
        cell.setup(unit: unit)
        return cell
    }
    
}

extension WeatherUnitsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newDefault = Array(setting.units.keys)[indexPath.row]
        setting._default = newDefault
        
        delegate?.save(updated: setting)
        navigationController?.popViewController(animated: true)
    }
}


extension WeatherUnitsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: Constants.cellSpace, bottom: 0, right: Constants.cellSpace)
    }
    
}

