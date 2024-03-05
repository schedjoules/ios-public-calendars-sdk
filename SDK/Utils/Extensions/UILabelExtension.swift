//
//  UILabelExtension.swift
//  iOS-SDK
//
//  Created by Irmak Ozonay on 3.03.2024.
//  Copyright © 2024 SchedJoules. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func colorString(text: String?, coloredText: String?, color: UIColor? = .red) {
        
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }
}
