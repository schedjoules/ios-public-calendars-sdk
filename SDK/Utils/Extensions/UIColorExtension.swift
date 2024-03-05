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
                return UIColor(named: "BackgroundColor") ?? .systemBackground
            } else {
                return .white
            }
        }
    }
    
    static let randomColors = [
        UIColor.getColorFromHex(hexString: "9A9CF8"),
        UIColor.getColorFromHex(hexString: "C37068"),
        UIColor.getColorFromHex(hexString: "4DA56B"),
        UIColor.getColorFromHex(hexString: "B49BF8"),
        UIColor.getColorFromHex(hexString: "ADDFE6"),
        UIColor.getColorFromHex(hexString: "A4DFC2"),
        UIColor.getColorFromHex(hexString: "F3B05A"),
        UIColor.getColorFromHex(hexString: "52AAF2"),
        UIColor.getColorFromHex(hexString: "59A8D7"),
        UIColor.getColorFromHex(hexString: "C076DB"),
        UIColor.getColorFromHex(hexString: "F09A38"),
        UIColor.getColorFromHex(hexString: "8595AD"),
    ]
    
    static func getColorFromHex(hexString : String, alpha: Float = 1.0) -> UIColor{
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
