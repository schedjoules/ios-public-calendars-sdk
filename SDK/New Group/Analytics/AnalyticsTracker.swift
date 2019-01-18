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
    private let loopTime: Int = 30
    private let urlString = "https://api.schedjoules.com/collect/"
    
    
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
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    private func systemDictionary() -> NSDictionary {
        
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
            
            let parameters = [
                "hits" : events,
                "system": self.systemDictionary(),
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
                    self.deleteEvents(events.count)
                    print("success")
                } else {
                    print("fail")
                }
                
            }
            
            task.resume()
        }
    }
    
    func deleteEvents(_ count: Int) {
        
        
        
        
//        var array = [1,2,3,4,5,6,7,8,9,0,"a","b","c"] as [Any]
//        let prefix = array.prefix(count)
//        let suffix1 = array.suffix(count)
//        let suffix2 = array.suffix(array.count - count)
//
//        print(array)
//        print(prefix)
//        print(suffix1)
//        print(suffix2)
        
        
        
        
        
        print("number evnts: ", count)
        let allEvents = UserDefaults.standard.trackingEvents
        print("allEvents ", allEvents.count)
        let remainingEvents = Array(allEvents.suffix(allEvents.count - count))
        print("leftEvents ", remainingEvents.count)
        
        
        
        print("count first: ", UserDefaults.standard.trackingEvents.count)
        UserDefaults.standard.trackingEvents = remainingEvents
        print("count later: ", UserDefaults.standard.trackingEvents.count)
        
        self.finishProcessing()
    }
    
    private func loopEvents() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(loopTime), qos: .background) {
            if self.isProcessing == true {
                print("loopEvents true")
                self.loopEvents()
            } else {
                print("loopEvents false")
                self.isProcessing = true
                self.uploadEvents()
            }
        }
    }
    
    
    //MARK: Tracking events
    
    func trackScreen(name: String?, pageId: Int) {
        
        //        let atracker: CalStoreAnalyticsTracker?
        
        
        //1. Create a hit
        let eventInfo = [
            "type":"screen",
             "timestamp":1547012994,
             "url":"https://api.schedjoules.com/pages?locale=es_MX&location=mx",
             "name":"swift-main-view",
             "pageId":117846
            ] as [String : AnyObject]
        
        //2. queue the hit
        track(event: eventInfo)
        
    }
}
