//
//  WeatherSettingsView.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/5/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient

protocol WeatherSettingsViewDelegate: AnyObject {
    func open(setting: WeatherSettingsItem)
}

class WeatherSettingsView: UIView {
    
    weak var delegate: WeatherSettingsViewDelegate?
    private var _setting: WeatherSettingsItem
    var setting: WeatherSettingsItem {
        get {
            return _setting
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var unitLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.textColor = .gray
        return label
    }()
    
    
    init(setting: WeatherSettingsItem) {
        self._setting = setting
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(unitLabel)
        
        titleLabel.text = setting.title
        unitLabel.text = setting.units[setting._default] ?? ""
        
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: 44)
        heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            unitLabel.topAnchor.constraint(equalTo: topAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            unitLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(settingSelected))
        self.addGestureRecognizer(tap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(setting: WeatherSettingsItem) {
        self._setting = setting
        unitLabel.text = setting.units[setting._default] ?? ""
    }
    
    
    // MARK: Actions
    
    @objc func settingSelected() {
        delegate?.open(setting: setting)
    }
    
}
