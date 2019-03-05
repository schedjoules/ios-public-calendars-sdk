//
//  SJSecureStorage.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 3/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import Security




public struct SJSecureStorage {
    
    public enum SJType: String {
        case api
    }
    
    let secureStorageQueryable: SJSecureStorageQueryable
    
    var apiKey: String? {
        get {
            do {
                let value = try getValue(for: .api)
                return value
            }
            catch {
                return nil
            }
        }
        set {
            guard let value = newValue else { return }
            do {
                try setValue(value, for: .api)
            }
            catch {
                return
            }
        }
    }
    
    public init(type: SJSecureStorage.SJType) {
        switch type {
        case .api:
            self.secureStorageQueryable = SJApiSecureStorageQueryable()
        }
    }
    
    public func setValue(_ value: String, for type: SJType) throws {
        
        //Check if the string can be turned into a Data type
        guard let encodedValue = value.data(using: .utf8) else {
            throw SJSecureStoreError.string2DataConversionError
        }
        
        //Setup the query
        var query = secureStorageQueryable.query
        query[String(kSecAttrAccount)] = type.rawValue
        
        //Return the keychain item that matches the query.
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
            //If the query succeeds it means the api already exists so we update it
        case errSecSuccess:
            var attributesToUpdate: [String : Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedValue
            
            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
            //If it cannot find an item, it doesn't exist, so we add it
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedValue
            
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
        default:
            throw error(from: status)
        }
    }
    
    public func getValue(for type: SJType) throws -> String? {
        // 1
        var query = secureStorageQueryable.query
        
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = type.rawValue
        
        // 2
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        switch status {
        // 3
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let passwordData = queriedItem[String(kSecValueData)] as? Data,
                let password = String(data: passwordData, encoding: .utf8)
                else {
                    throw SJSecureStoreError.data2StringConversionError
            }
            return password
        // 4
        case errSecItemNotFound:
            return nil
        default:
            throw error(from: status)
        }
    }
    
    public func removeValue(for userAccount: String) throws {
        
    }
    
    public func removeAllValues() throws {
        
    }
    
    private func error(from status: OSStatus) -> SJSecureStoreError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        return SJSecureStoreError.unhandledError(message: message)
    }
}



public enum SJSecureStoreError: Error {
    case string2DataConversionError
    case data2StringConversionError
    case unhandledError(message: String)
}

extension SJSecureStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .string2DataConversionError:
            return NSLocalizedString("String to Data conversion error", comment: "")
        case .data2StringConversionError:
            return NSLocalizedString("Data to String conversion error", comment: "")
        case .unhandledError(let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}

