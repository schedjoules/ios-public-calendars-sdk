//
//  ItemCollectionViewCell.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 6/5/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient

protocol ItemCollectionViewCellDelegate: AnyObject {
    func subscribe(to pageItem: PageItem)
}

class ItemCollectionViewCell: UITableViewCell {
    
    weak var delegate: ItemCollectionViewCellDelegate?
    var pageItem: PageItem?
    
    private let itemLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    //MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(itemLabel)
        addSubview(itemImageView)
        
        NSLayoutConstraint.activate([
            itemImageView.widthAnchor.constraint(equalToConstant: 44),
            itemImageView.heightAnchor.constraint(equalToConstant: 44),
            itemImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            itemImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            itemImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
            
            itemLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 74),
            itemLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -44),
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
        
        // Add subscribe button if item is a calendar item
        if pageItem.itemClass == .calendar {
            let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            addButton.setImage(UIImage(named: "Add", in: Bundle.resourceBundle,
                                       compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.imageView?.tintColor = tintColor
            addButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)
            accessoryView = addButton
            isUserInteractionEnabled = true
            accessoryView?.isUserInteractionEnabled = true
            // Else add a disclosure indicator
        } else {
            accessoryType = .disclosureIndicator
            accessoryView = nil
        }
    }
    
    @objc private func subscribe() {
        guard let pageItem = pageItem else {
            return
        }
        
        delegate?.subscribe(to: pageItem)
    }
    
}
