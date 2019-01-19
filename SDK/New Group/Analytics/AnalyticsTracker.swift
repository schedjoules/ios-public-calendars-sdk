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
    
    
    struct Keys {
        struct Events {
            static let hits = "hits"
            static let name = "name"
            static let pageId = "pageId"
            static let system = "system"
            static let timestamp = "timestamp"
            static let type = "type"
            static let url = "url"
            static let uuid = "uuid"
        }
        
        struct EventType {
            static let sessionStart = "session-start"
            static let sessionEnd = "session-end"
            static let event = "event"
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
    
    public func launch() {
        loopEvents()
    }
    
    private func track(event: [String : AnyObject]) {
        DispatchQueue.global(qos: .background).async {
            var events = UserDefaults.standard.trackingEvents
            events.append(event)
            UserDefaults.standard.trackingEvents = events
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
        self.loopEvents()
    }
    
    private func uploadEvents() {
        DispatchQueue.global(qos: .background).async {
            
            guard let events = UserDefaults.standard.trackingEvents.splitBy(size: self.sizeForUpload).first else {
                print("all events uploaded")
                self.finishProcessing()
                return
            }
            print("events to upload: ", UserDefaults.standard.trackingEvents.count)
            
            let parameters = [
                Keys.Events.hits : events,
                Keys.Events.system : self.systemDictionary(),
                Keys.Events.timestamp : Config.dateForAnalytics,
                Keys.Events.uuid : Config.uuid
                ] as [String : AnyObject]
            
            guard let url = URL(string: self.urlString) else {
                print("url isn't valid")
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setHeaders(for: .analytics)
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                // check for any errors
                
                if let error = error {
                    print("error:", error)
                    return
                }
                
                guard let result = response as? HTTPURLResponse else {
                    print("no response")
                    return
                }
                
                
                if result.statusCode == 200 {
                    self.deleteEvents(events.count)
                    print(events)
                    print("success")
                } else {
                    print("fail")
                }
                
            }
            
            task.resume()
        }
    }
    
    func deleteEvents(_ count: Int) {
        let allEvents = UserDefaults.standard.trackingEvents
        let remainingEvents = Array(allEvents.suffix(allEvents.count - count))
        UserDefaults.standard.trackingEvents = remainingEvents
        
        self.finishProcessing()
    }
    
    private func loopEvents() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(loopTime), qos: .background) {
            if self.isProcessing == true {
                self.loopEvents()
            } else {
                self.isProcessing = true
                self.uploadEvents()
            }
        }
    }
    
    
    //MARK: Tracking events
    
    func trackScreen(name: String?, page: Page?, url: URL?) {
        var eventInfo = [
            Keys.Events.type : Keys.EventType.screen,
            Keys.Events.timestamp : Config.dateForAnalytics
            ] as [String : AnyObject]
        
        let name: String? = page?.name ?? name
        if let validName = name {
            eventInfo[Keys.Events.name] = validName as AnyObject
        }
        
        if let pageId = page?.itemID {
            eventInfo[Keys.Events.pageId] = pageId as AnyObject
        }
        
        if let url = url {
            eventInfo[Keys.Events.url] = url.absoluteString as AnyObject
        }
        
        track(event: eventInfo)
    }
}
