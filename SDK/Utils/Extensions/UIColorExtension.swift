//
//  UIColorExtension.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 02. 21..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit

public extension UIColor {
    
    static let sjBlue = UIColor(red: 7/255, green: 118/255, blue: 189/255, alpha: 1.0)
    static let sjBlueLight = UIColor(red: 102/255, green: 154/255, blue: 204/255, alpha: 1.0)
    static let sjBlueBright = #colorLiteral(red: 0, green: 0.6039215686, blue: 1, alpha: 1)
    static let sjGrayLight = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    static let sjRed = UIColor(red: 241/255.0, green: 102/255.0, blue: 103/255.0, alpha: 1.0)
    static let sjIntroBackground = UIColor(red: 106/255.0, green: 202/255.0, blue: 202/255.0, alpha: 1.0)
    static var sjBackground: UIColor {
        get {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }
    }
    
}
