//
//  WeatherOptionCollectionViewCell.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/5/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit

class WeatherOptionCollectionViewCell: UICollectionViewCell {
    
    func setup(option: String) {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = option
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22)
        label.textColor = .sjBlue
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.sizeToFit()
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.borderColor = UIColor.sjBlueLight.cgColor
        layer.borderWidth = 1.0
        clipsToBounds = true
    }
}
