//
//  RecommendationsCollectionViewCell.swift
//  iOS-SDK
//
//  Created by Alberto on 03/06/22.
//  Copyright © 2022 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient

class RecommendationsCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    var pageItem: PageItem?
    
    private let itemLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: UI
    private let itemImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(itemLabel)
        addSubview(itemImageView)
        
        NSLayoutConstraint.activate([
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            itemImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            itemImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            itemLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 2),
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            itemLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            itemLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -6),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Setup
    public func setup(pageItem: PageItem, tintColor: UIColor? = .black) {
        self.pageItem = pageItem
        
        // Set text label to the page item's name
        itemLabel.text = pageItem.name
        
        // Set icon (if any)
        itemImageView.image = nil
        if pageItem.icon != nil {
            itemImageView.sd_setImage(with: pageItem.icon!,
                                      placeholderImage: UIImage(named: "Icon_Placeholder",
                                                                in: Bundle.resourceBundle,
                                                                compatibleWith: nil))
        }
    }
    
}
