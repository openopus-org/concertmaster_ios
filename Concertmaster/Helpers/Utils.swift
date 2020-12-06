//
//  Library.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 06/12/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import Foundation

public func APIBearerGet(_ url: String, bearer: String, completion: @escaping (Data) -> ()) {
    
    guard let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
        let urlR = URL(string: encoded) else
    {
        fatalError("Invalid URL")
    }
    
    print("✅ \(url)")
    
    var request = URLRequest(url: urlR)
    request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 3000000.0
    sessionConfig.timeoutIntervalForResource = 6000000.0
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        
        if let data = data {
            completion(data)
        }
        
    }.resume()
}

public func APIBearerPost(_ url: String, parameters: [String: Any], bearer: String, completion: @escaping (Data) -> ()) {
    
    guard let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
        let urlR = URL(string: encoded) else
    {
        fatalError("Invalid URL")
    }
    
    print("✅ \(url)")
    parameters.forEach() { print("✴️ \($0)") }
    
    var request = URLRequest(url: urlR)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    request.httpBody = parameters.percentEncoded()
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 3000000.0
    sessionConfig.timeoutIntervalForResource = 6000000.0
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        
        if let data = data {
            completion(data)
        }
        
    }.resume()
}
