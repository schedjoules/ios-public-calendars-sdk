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

class WeatherMapDataSource {
    
    struct WeatherMapRequest {
        var httpMethod = "GET"
        let apiKey = "4f8a4d80e0b5079806cd344ce3095272"
        
        func cities(northEastCoordinate: CLLocationCoordinate2D, southWestCoordinate: CLLocationCoordinate2D) -> URLRequest? {
            var urlComponents = URLComponents(string: "https://api.schedjoules.com/cities/cities_within_bounds")
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
        
        func cityWeather(locationId: String) -> URLRequest? {
            var urlComponents = URLComponents(string: "https://api.schedjoules.com/cities/weather_settings?locale=en")
//            urlComponents?.queryItems = [
//                URLQueryItem(name: "loc", value: "\(locationId)"),
//            ]
            
            guard let url = urlComponents?.url else { return nil }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = self.httpMethod
            urlRequest.setHeaders(for: .analytics, apiKey: apiKey)
            
            return urlRequest
        }
        
    }
    
    func getWeatherPoints(northEastCoordinate: CLLocationCoordinate2D, southWestCoordinate: CLLocationCoordinate2D, completion: @escaping (_ array: [WeatherCity], _ error: Error?) -> Void) {
        guard let urlRequest = WeatherMapRequest().cities(northEastCoordinate: northEastCoordinate, southWestCoordinate: southWestCoordinate) else { return }
        
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
                    completion([], nil)
                    return
                }
                
                do {
                    let cities = try JSONDecoder().decode([WeatherCity].self, from: data)
                    completion(cities, nil)
                    return
                } catch {
                    sjPrint(error)
                }
                
                completion([], nil)
            }
            
            task.resume()
            
        }
    }    
    
    func getWeatherSettings(locationId: String, completion: @escaping (_ array: [AnyObject], _ error: Error?) -> Void) {
        guard let urlRequest = WeatherMapRequest().cityWeather(locationId: locationId) else { return }
        
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
                
                print(error)
                print(data)
                print(result)
                
                guard let validData = data else { return }
                
                do {
                    let dataInfo = try JSONSerialization.jsonObject(with: validData, options: [.allowFragments])
                    print(dataInfo)
                } catch {
                    print("error: ", error)
                }
                
                print(response)
                print("stop")
                
                completion([], nil)
                
            }
            
            task.resume()
                
            }
    }

}
