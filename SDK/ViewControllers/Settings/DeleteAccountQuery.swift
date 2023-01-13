//
//  DeleteAccountQuery.swift
//  iOS-SDK
//
//  Created by Alberto on 19/07/22.
//  Copyright © 2022 SchedJoules. All rights reserved.
//

import SchedJoulesApiClient

public final class DeleteAccountQuery: Query {
    
    public typealias Result = String
    
    public let url: URL = URL(string:"https://api.schedjoules.com/remove_account")!
    public let method: SJHTTPMethod = .post
    public let parameters: [String : AnyObject]
    public let headers: [String : String] = ["Accept" : "application/json",
                                             "Content-Type" : "application/json",
                                             "x-app-id" : Bundle.main.bundleIdentifier ?? "",
                                             "x-user-id" : UIDevice.current.identifierForVendor?.uuidString ?? "",
                                             "x-locale" : Locale.current.regionCode ?? ""]
    
    
    public init(subscriptionId: String?,
                userIdentifier: String) {
        var dictionary = [
            "user_identifier": userIdentifier
        ]
        
        if let subscriptionId = subscriptionId {
            dictionary["sid"] = subscriptionId
        }
        
        self.parameters = dictionary as [String : AnyObject]
        print(url)
        print("delete parameters: ", self.parameters)
        print("")
        
        
        
        
    }
    
    public func handleResult(with data: Data) -> String? {
        print("migration data: ", data)
        do {
            let rawjson = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            print("rawjson: ", rawjson)
            let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: AnyObject]
            print("json: ", json)
            return "json valid"
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
}
