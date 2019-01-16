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
            
            let authorization = "Token token=\"0443a55244bb2b6224fd48e0416f0d9c\""
            let fullHeaders: HTTPHeaders = [
                "Accept" : "application/vnd.schedjoules; version=1",
                "Authorization" : authorization,
                "Cache-Control" : "no-cache",
                "Content-Type" : "application/json",
                "Postman-Token" : "6637f090-4fbb-ecbb-bddc-1d136032c456",
                "User-Agent" : "CalendarStore/2.3.4 (iPhone; U; CPU iOS 12.1.2 like Mac OS X; es-mx-mx)",
                "X-CalendarStore-AppId" : "com.schedjoules.allmighty/9.0.4",
                "X-CalendarStore-Library-Version" : "2.3.4-4-g8cd554c",
                "X-CalendarStore-UUID" : "721E27E3-809C-4B7E-9B81-F500B0728457",
                "X-CalendarStore-iOS" : "12.1.2",
                "x-app-id" : "com.schedjoules.allmighty/9.0.4",
                "x-locale" : "es_MX",
                "x-user-Id" : "721E27E3-809C-4B7E-9B81-F500B0728457"
            ]
            
            guard let url = URL(string: "https://api.schedjoules.com/collect/") else { fatalError("vale verga la vida") }
            
            var urlRequest = URLRequest(url: url)
            
            for key in fullHeaders.keys {
                urlRequest.setValue(fullHeaders[key], forHTTPHeaderField: key)
            }
            
            
            urlRequest.httpMethod = "POST"
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            let session = URLSession.shared
            
            
            
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                // check for any errors
                
                print(response)
                print(response?.description)
                print(data)
                
                
                if self.count < 20 {
                    self.count = self.count + 1

                    self.uploadEvents()
                }
            }
            
            task.resume()
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    
    
    func urlRequest(forHits hits: [Any]?) -> URLRequest? {
        
        print(self.authorizationTokenFromMainBundle())
        
        let url = URL(string: "https://api.schedjoules.com/collect/")
        let requestInfo = dictionary(forBatch: hits)
        let userAgentString = self.userAgentString()
        
        return self.calstore_request(with: url, jsonable: requestInfo, userAgent: userAgentString)
    }
    
    //Authorization token
    let kCalStoreCalendarStoreAuthorizationTokenKey = "CalendarStoreAuthorizationToken"
    let kCalStoreAcceptHeaderValue = "application/vnd.schedjoules; version=1"
    
    func authorizationTokenFromMainBundle() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: kCalStoreCalendarStoreAuthorizationTokenKey) as? String
    }
    
    //Helper of urlRequest(forHits:)
    func dictionary(forBatch hits: [Any]?) -> [AnyHashable : Any]? {
        var requestInfo: [AnyHashable : Any] = [:]
        requestInfo["system"] = self.systemDictionary()
        requestInfo["timestamp"] = Date().timeIntervalSince1970
        requestInfo["uuid"] = calstore_stringWithUUID()
        
        
        requestInfo["hits"] = hits
        //Alberto's code
//        let allEvents = UserDefaults.standard.trackingEvents
//        if allEvents.count > 0 ,
//            let eventsToUpload = allEvents.splitBy(size: self.sizeForUpload).first {
//            requestInfo["hits"] = hits
//        }
        
        return requestInfo
    }
    
    //Helper of dictionary(forBatch:)
    func calstore_stringWithUUID() -> String {
        let uuid = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuid) as String?
        
        return uuidString ?? ""
    }
    
    //Helper of urlRequest(forHits:)
    static let KCalStoreAnalyticsUserAgentFormat = "%@/%@ (%@; U; CPU %@ %@ like Mac OS X; %@-%@)"
    static let kCalStoreAnalyticsProductName = "CalendarStore";
    func userAgentObject() -> NSObject {
        let userAgent: NSObject = NSObject.init()
        userAgent.setValue(systemDictionary(), forKey: "systemInfo")
        return userAgent
    }
    func userAgentString() -> String? {
        let languageSetting = SettingsManager.get(type: .language)
        let countrySetting = SettingsManager.get(type: .country)
        
        return userAgent(withProductName: AnalyticsTracker.kCalStoreAnalyticsProductName,
                         productVersion: "2.3.4" /* don't include the git revision number */,
            deviceModel: UIDevice.current.model,
            systemName: UIDevice.current.systemName,
            systemVersion: UIDevice.current.systemVersion,
            systemLanguage: languageSetting.code,
            systemCountry: countrySetting.code)
    }
    
    
    func userAgent(withProductName productName: String?, productVersion: String?, deviceModel: String?, systemName: String?, systemVersion: String?, systemLanguage: String?, systemCountry: String?) -> String? {
        return String(format: AnalyticsTracker.KCalStoreAnalyticsUserAgentFormat, productName ?? "", productVersion ?? "", deviceModel ?? "", systemName ?? "", systemVersion ?? "", systemLanguage ?? "", systemCountry ?? "")
    }
    
    
    
    
    
    
    
    func calstore_request(with url: URL?, jsonable: Any?, userAgent: String?) -> URLRequest {
        var urlRequest: URLRequest? = nil
        if let url = url {
            urlRequest = URLRequest(url: url)
        }
        
        // set the user agent
        if userAgent != nil {
            //EDITED
            urlRequest?.setValue("CalendarStore/2.3.4 (iPhone; U; CPU iOS 12.1 like Mac OS X; en-us)", forHTTPHeaderField: "User-Agent")
        }
        
        // set the JSON
        urlRequest?.httpMethod = "POST"
        
        
        print("jsonable: ", jsonable)
        
        
        if let body = self.calstore_jsonString(fromObject: jsonable, error: nil),
            let bodyData = body.data(using: .utf8) {
            print("body: ", body)
            urlRequest?.httpBody = bodyData
        }
        
        urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let contentLength = String(format: "%lu", UInt(urlRequest?.httpBody?.count ?? 0))
        urlRequest?.setValue("Token token=\"0443a55244bb2b6224fd48e0416f0d9c\"", forHTTPHeaderField: "Authorization")
        urlRequest?.setValue("application/vnd.schedjoules; version=1", forHTTPHeaderField: "Accept")
        
        
        urlRequest?.setValue("application/vnd.schedjoules; version=1", forHTTPHeaderField: "Accept")
        urlRequest?.setValue("Token token=\"0443a55244bb2b6224fd48e0416f0d9c\"", forHTTPHeaderField: "Authorization")
        urlRequest?.setValue(contentLength, forHTTPHeaderField: "Content-Length")
        urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest?.setValue("CalendarStore/2.3.4 (iPhone; U; CPU iOS 12.1.2 like Mac OS X; es-mx-mx)", forHTTPHeaderField: "User-Agent")
        urlRequest?.setValue("com.schedjoules.allmighty/9.0.4", forHTTPHeaderField: "X-CalendarStore-AppId")
        urlRequest?.setValue("2.3.4-4-g8cd554c", forHTTPHeaderField: "X-CalendarStore-Library-Version")
        urlRequest?.setValue("cca09e24-0946-4a80-8d76-221d4d42c526", forHTTPHeaderField: "X-CalendarStore-UUID")
        urlRequest?.setValue("12.1.2", forHTTPHeaderField: "X-CalendarStore-iOS")
        urlRequest?.setValue("com.schedjoules.allmighty/9.0.4", forHTTPHeaderField: "x-app-id")
        urlRequest?.setValue("es_MX", forHTTPHeaderField: "x-locale")
        urlRequest?.setValue("cca09e24-0946-4a80-8d76-221d4d42c526", forHTTPHeaderField: "x-user-Id")
        
        
        
        
        
        return urlRequest!
    }
    
    
    //Ayudante de calstore_request
    func calstore_jsonString(fromObject object: Any?, error: NSError?) -> String? {
        #if false
        if !JSONSerialization.self {
            return nil
        }
        #endif
        
        if object == nil {
            return nil
        }
        
        var localError: Error? = nil
        var data: Data? = nil
        if let object = object {
            data = try? JSONSerialization.data(withJSONObject: object, options: [])
        }
        if localError != nil {
            print("Error encoding to JSON: ", localError)
        }
        
        if let data = data {
            return data != nil ? String(data: data, encoding: .utf8) : nil ?? ""
        }
        return nil
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
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
    
    func trackSearchBegin() {/*
        let name = "begin"
        let category = "search"
        let value: String? = nil
        let event = [
            "category" : category,
            "name" : name,
            "value" : value ?? ""
        ]
        let type = "event"
        
        let apiHost = "https://api.schedjoules.com"
        let analyticsEndpoint = "/collect/"
        guard let url = URL(string: "\(apiHost)\(analyticsEndpoint)") else { return }
        
        let urlRequest = NSMutableURLRequest.init(url: url)
        
        let body = String.calstore_jsonString(fromObject: jsonable)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body.data(using: .utf8)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(String(format: "%lu", UInt(urlRequest.httpBody?.count ?? 0)), forHTTPHeaderField: "Content-Length")

        
        
        NSMutableDictionary* requestInfo = [NSMutableDictionary dictionary];
        requestInfo[@"system"]    = self.systemInfo.dictionary;
        requestInfo[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
        requestInfo[@"uuid"]      = self.userUuid;
        requestInfo[@"hits"]      = [hits calstore_map:^(CalStoreAnalyticsHit* hit){return hit.dictionary;}];
        
        
        */
    }
}
