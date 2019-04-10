//
//  AnalyticsTracker.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 01. 01..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import UIKit
import SchedJoulesApiClient

class AnalyticsTracker: NSObject {
    
    private var isProcessing: Bool = false
    private let sizeForUpload: Int = 20
    private let loopTime: Int = 30
    private let urlString = "https://api.schedjoules.com/collect/"
    private var apiKey: String?
    
    
    struct Keys {
        struct Hits {
            static let hits = "hits"
            static let name = "name"
            static let pageId = "pageId"
            static let system = "system"
            static let timestamp = "timestamp"
            static let type = "type"
            static let url = "url"
            static let uuid = "uuid"
        }
        
        struct HitType {
            static let sessionStart = "session-start"
            static let sessionEnd = "session-end"
            static let hit = "hit"
            static let screen = "screen"
            static let purchase = "purchase"
        }
        
        struct System {
            static let language = "language"
            static let country = "country"
            static let resolution = "screenResolution"
            static let bundleIdentifier = "appBundleIdentifier"
            static let appVersion = "appVersion"
            static let deviceModel = "deviceHardwareModel"
        }
        
    }
    
    
    @objc class func shared() -> AnalyticsTracker {
        let shared = AnalyticsTracker()
        
        return shared
    }
    
    public func launch(with apiKey: String) {
        self.apiKey = apiKey
        loopHits()
    }
    
    private func track(hit: [String : AnyObject]) {
        DispatchQueue.global(qos: .background).async {
            var hits = UserDefaults.standard.trackingHits
            hits.append(hit)
            UserDefaults.standard.trackingHits = hits
        }
    }
    
    private func systemDictionary() -> [String : String] {
        let dictionary = [
            Keys.System.language : SettingsManager.get(type: .language).code,
            Keys.System.country : SettingsManager.get(type: .country).code,
            Keys.System.resolution : "\(UIScreen.main.bounds.width)x\(UIScreen.main.bounds.height)",
            Keys.System.bundleIdentifier : Config.bundleIdentifier,
            Keys.System.appVersion : Config.bundleVersion,
            Keys.System.deviceModel : UIDevice.current.model
        ]
        return dictionary
    }
    
    private func finishProcessing() {
        self.isProcessing = false
        self.loopHits()
    }
    
    private func uploadHits() {
        DispatchQueue.global(qos: .background).async {
            
            guard let hits = UserDefaults.standard.trackingHits.splitBy(size: self.sizeForUpload).first else {
                sjPrint("all hits uploaded")
                self.finishProcessing()
                return
            }
            sjPrint("hits to upload: ", UserDefaults.standard.trackingHits.count)
            
            let parameters = [
                Keys.Hits.hits : hits,
                Keys.Hits.system : self.systemDictionary(),
                Keys.Hits.timestamp : Config.dateForAnalytics,
                Keys.Hits.uuid : Config.uuid
                ] as [String : AnyObject]
            
            guard let url = URL(string: self.urlString) else {
                sjPrint("url isn't valid")
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setHeaders(for: .analytics, apiKey: self.apiKey)
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                sjPrint(error.localizedDescription)
            }
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                // check for any errors
                
                if let error = error {
                    sjPrint("error:", error)
                    return
                }
                
                guard let result = response as? HTTPURLResponse else {
                    sjPrint("no response")
                    return
                }
                
                
                if result.statusCode == 200 {
                    self.deleteHits(hits.count)
                    sjPrint(hits)
                    sjPrint("success")
                } else {
                    sjPrint("fail")
                }
                
            }
            
            task.resume()
        }
    }
    
    func deleteHits(_ count: Int) {
        let allHits = UserDefaults.standard.trackingHits
        let remainingHits = Array(allHits.suffix(allHits.count - count))
        UserDefaults.standard.trackingHits = remainingHits
        
        self.finishProcessing()
    }
    
    private func loopHits() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(loopTime), qos: .background) {
            if self.isProcessing == true {
                self.loopHits()
            } else {
                self.isProcessing = true
                self.uploadHits()
            }
        }
    }
    
    
    //MARK: Tracking hits
    
    func trackScreen(name: String?, page: Page?, url: URL?) {
        var hitInfo = [
            Keys.Hits.type : Keys.HitType.screen,
            Keys.Hits.timestamp : Config.dateForAnalytics
            ] as [String : AnyObject]
        
        let name: String? = page?.name ?? name
        if let validName = name {
            hitInfo[Keys.Hits.name] = validName as AnyObject
        }
        
        if let pageId = page?.itemID {
            hitInfo[Keys.Hits.pageId] = pageId as AnyObject
        }
        
        if let url = url {
            hitInfo[Keys.Hits.url] = url.absoluteString as AnyObject
        }
        
        track(hit: hitInfo)
    }
}
