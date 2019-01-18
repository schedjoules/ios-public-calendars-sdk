//
//  AnalyticsTracker.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 01. 01..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AnalyticsTracker: NSObject {
    
    private var isProcessing: Bool = false
    private let sizeForUpload: Int = 5
    private let urlString = "https://api.schedjoules.com/collect/"
    
    
    @objc class func shared() -> AnalyticsTracker {
        let shared = AnalyticsTracker()
        return shared
    }
    
    private func track(event: [String : AnyObject]) {
        
        isProcessing = true
        
        DispatchQueue.global(qos: .background).async {
            var events = UserDefaults.standard.trackingEvents
            events.append(event)
            UserDefaults.standard.trackingEvents = events
            
            self.uploadEvents()
        }
    }
    
    private func trackEvent(name: String, details: [String : AnyObject]?) {
        
        isProcessing = true
        
        DispatchQueue.global(qos: .background).async {
            
            //Create the details dictionary that will be saved
            var newEventDictionary: [String : AnyObject] = ["name" : name as AnyObject]
            
            //Details
            if let validDetails = details {
                newEventDictionary.merge(validDetails) { (_, new) in new }
            }
            
            var events = UserDefaults.standard.trackingEvents
            events.append(newEventDictionary)
            UserDefaults.standard.trackingEvents = events
            
            self.isProcessing = false
        }
        
    }
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func systemDictionary() -> NSDictionary {
        
        let languageSetting = SettingsManager.get(type: .language)
        let countrySetting = SettingsManager.get(type: .country)
        let screenResolution = "\(UIScreen.main.bounds.width)x\(UIScreen.main.bounds.height)"
        let appBundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0.0.0"
        let deviceHardwareModel = modelIdentifier()
        
        return [
            "language" : languageSetting.code,
            "country": countrySetting.code,
            "screenResolution" : screenResolution,
            "appBundleIdentifier" : appBundleIdentifier,
            "appVersion" : appVersion,
            "deviceHardwareModel" : deviceHardwareModel
        ]
    }
    
    var count = 0
    private func uploadEvents() {
        DispatchQueue.global(qos: .background).async {
            
            let parameters = [
                "hits" : [
                    ["type":"screen",
                     "timestamp":1547012994,
                     "url":"https://api.schedjoules.com/pages?locale=es_MX&location=mx",
                     "name":"swift-main-view",
                     "pageId":117846]
                ],
                "system":
                    [
                        "language":"es-mx"
                ],
                "timestamp":1547013002,
                "uuid":"721E27E3-809C-4B7E-9B81-F500B0728457"
                ] as [String : AnyObject]
            
            guard let url = URL(string: self.urlString) else { fatalError("url isn't valid") }
            
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
                    self.deleteEvents()
                    print("success")
                } else {
                    print("fail")
                }
                
            }
            
            task.resume()
        }
    }
    
    func deleteEvents() {
        let allEvents = UserDefaults.standard.trackingEvents
        let remainingEvents = Array(allEvents.suffix(sizeForUpload))
        UserDefaults.standard.trackingEvents = remainingEvents
        self.loopEvents()
    }
    
    private func loopEvents() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(30), qos: .background) {
            if self.isProcessing == true {
                self.loopEvents()
            } else {
                self.uploadEvents()
            }
        }
    }
    
    
    //MARK: Tracking events
    
    func trackScreen(name: String?, pageId: Int) {
        
        //        let atracker: CalStoreAnalyticsTracker?
        
        
        //1. Create a hit
        let eventInfo = [
            "type" : "screen",
            "name" : name ?? "",
            "pageId" : pageId,
            "timestamp" : Date().timeIntervalSince1970 as NSNumber
            ] as [String : AnyObject]
        
        //2. queue the hit
        track(event: eventInfo)
        
    }
}
