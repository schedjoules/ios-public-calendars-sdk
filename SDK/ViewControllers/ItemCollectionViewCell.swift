//
//  ItemCollectionViewCell.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 6/5/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit
import SchedJoulesApiClient

protocol ItemCollectionViewCellDelegate: class {
    func subscribe(to pageItem: PageItem)
}

class ItemCollectionViewCell: UITableViewCell {
    
    weak var delegate: ItemCollectionViewCellDelegate?
    var pageItem: PageItem?
    
    func setup(pageItem: PageItem, tintColor: UIColor? = .black) {
        self.pageItem = pageItem
        
        // Set text label to the page item's name
        textLabel?.text = pageItem.name
        
        // Set icon (if any)
        imageView!.image = nil
        if pageItem.icon != nil{
            imageView!.sd_setImage(with: pageItem.icon!,
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
