//
//  WeatherMapDataSource.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/2/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation
import MapKit

protocol APIRequestConvertible {
    var path: String { get }
    var method: String { get }
    var parameters: [String: Any]? { get }
}

class WeatherMapDataService {
    
    struct WeatherMapRequest {
        var httpMethod = "GET"
        let apiKey: String
        
        enum URLs {
            static let cities = "https://api.schedjoules.com/cities/cities_within_bounds"
            static let settings = "https://api.schedjoules.com/cities/weather_settings"
        }
        
        init(apiKey: String) {
            self.apiKey = apiKey
        }
        
        func cities(northEastCoordinate: CLLocationCoordinate2D, southWestCoordinate: CLLocationCoordinate2D) -> URLRequest? {
            var urlComponents = URLComponents(string: URLs.cities)
            urlComponents?.queryItems = [
                URLQueryItem(name: "ne", value: "\(northEastCoordinate.latitude),\(northEastCoordinate.longitude)"),
                URLQueryItem(name: "sw", value: "\(southWestCoordinate.latitude),\(southWestCoordinate.longitude)")
            ]
            
            guard let url = urlComponents?.url else { return nil }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = self.httpMethod
            urlRequest.setHeaders(for: .analytics, apiKey: apiKey)
            
            return urlRequest
        }
        
        func weatherSettings() -> URLRequest? {
            var urlComponents = URLComponents(string: URLs.settings)
            urlComponents?.queryItems = [
                URLQueryItem(name: "locale", value: SettingsManager.get(type: .language).code),
            ]
            
            guard let url = urlComponents?.url else { return nil }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = self.httpMethod
            urlRequest.setHeaders(for: .analytics, apiKey: apiKey)
            
            return urlRequest
        }
        
    }
    
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getWeatherPoints(northEastCoordinate: CLLocationCoordinate2D, southWestCoordinate: CLLocationCoordinate2D, completion: @escaping (_ array: [WeatherPointAnnotation], _ error: Error?) -> Void) {
        guard let urlRequest = WeatherMapRequest(apiKey: self.apiKey).cities(northEastCoordinate: northEastCoordinate, southWestCoordinate: southWestCoordinate) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            
            session.getTasksWithCompletionHandler({ (dataTasks, _, _) in
                for dataTask in dataTasks {
                    if let existingUrl = dataTask.originalRequest?.url,
                        let newUrl = urlRequest.url,
                        existingUrl.path == newUrl.path {
                        dataTask.cancel()
                    }
                }
                
                let task = session.dataTask(with: urlRequest) { (data, response, error) in
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
                        sjPrint("success")
                    } else {
                        sjPrint("fail")
                    }
                    
                    guard let data = data else {
                        completion([], nil)
                        return
                    }
                    
//                    do {
//                        let cities = try JSONDecoder().decode([WeatherPointAnnotation].self, from: data)
//                        completion(cities, nil)
//                        return
//                    } catch {
//                        sjPrint(error)
//                    }
                    
                    completion([], nil)
                }
                
                task.resume()
            })
        }
    }
    
    func getWeatherSettings(completion: @escaping (_ array: WeatherSettingsNO?, _ error: Error?) -> Void) {
        guard let urlRequest = WeatherMapRequest(apiKey: self.apiKey).weatherSettings() else { return }
        
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
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
                    sjPrint("success")
                } else {
                    sjPrint("fail")
                }
                
                
                guard let data = data else {
                    completion(nil, nil)
                    return
                }
                
                do {
                    let settings = try JSONDecoder().decode(WeatherSettingsNO.self, from: data)
                    completion(settings, nil)
                    return
                } catch {
                    sjPrint(error)
                }
                
                completion(nil, nil)
                
            }
            
            task.resume()
            
        }
    }
    
}
