//
//  StringExtension.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/5/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

extension String {
    
    //Method used to turn a url into a url to open webcal. Used for subscriptions
    func webcalURL() -> URL? {
        let urlBegin = self.range(of: "://")!.upperBound
        let urlString = self[urlBegin..<self.endIndex]
        
        var urlComponents = URLComponents(string: "webcal://\(urlString)")
        //UUID
        urlComponents?.queryItems?.append(URLQueryItem(name: "u", value: Config.uuid))
        //Subscription Id
        if let subscriptionId = UserDefaults.standard.subscriptionId {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid", value: subscriptionId))
        }
        
        return urlComponents?.url
    }
    
}

