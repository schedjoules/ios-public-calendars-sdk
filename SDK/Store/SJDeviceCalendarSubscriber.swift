//
//  SJCalendarSubscriber.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/22/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit
import EventKit

open class SJDeviceCalendarSubscriber {
    
    public static let shared = SJDeviceCalendarSubscriber()
    
    enum SubscriberError: Error {
        case unauthorized
        case missingURL
    }
    
    var calendarsSubscribed: [EKCalendar] = []
    var calendarId: Int = 0
    var url: URL!
    var screenName: String?
    var isSubscribing = false
    
    public func subscribe(to calendarId: Int, url: URL?, screenName: String?, _ completion: @escaping (_ error: Error?) -> Void) {
        hasAuthorization { (hasAuthorization) in
            guard hasAuthorization == true else {
                completion(SubscriberError.unauthorized)
                return
            }
            
            guard let url = url else {
                completion(SubscriberError.missingURL)
                return
            }
            
            self.isSubscribing = true
            
            self.calendarId = calendarId
            self.url = url
            self.screenName = screenName
            DispatchQueue.main.async {
                UIApplication.shared.open(url,
                                          options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: nil)
            }
        }
        
    }
    
    public func checkForNewCalendarsInDevice() {
        guard isSubscribing == true else {
            self.calendarsSubscribed = self.getUserCalendarSubscribed()
            return
        }
        
        let updatedCalendarsInDevice = getUserCalendarSubscribed()
        guard updatedCalendarsInDevice.count > 0 else {
            return
        }
        
        let calendarsSubscribedIds = self.calendarsSubscribed.map({ $0.calendarIdentifier })
        let updatedCalendarsInDeviceIds = updatedCalendarsInDevice.map({ $0.calendarIdentifier })
        let calendarsIdDifference = calendarsSubscribedIds.difference(from: updatedCalendarsInDeviceIds)
        
        guard calendarsIdDifference.count > 0 else {
            return
        }
        
        self.calendarsSubscribed = updatedCalendarsInDevice
        
        let sjCalendar =  SJAnalyticsCalendar(calendarId: calendarId, calendarURL: url)
        let sjEvent = SJAnalyticsObject(calendar: sjCalendar, screenName: screenName)
        NotificationCenter.default.post(name: .SJSubscribedToCalendar, object: sjEvent)
        
        isSubscribing = false
    }
    
    private func getUserCalendarSubscribed() -> [EKCalendar] {
        let eventStore = EKEventStore()
        let allCalendars = eventStore.calendars(for: .event)
        return allCalendars.filter({ $0.isSubscribed == true })
    }
    
    private func hasAuthorization(_ completion: @escaping (_ hasAuthorization: Bool) -> Void) {
        let currentStatus = EKEventStore.authorizationStatus(for: .event)
        switch currentStatus {
        case .authorized:
            completion(true)
            return
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            completion(false)
            return
        @unknown default:
            completion(false)
            return
        }
        
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (success, error) in
            completion(success)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
