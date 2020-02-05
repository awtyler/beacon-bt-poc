//
//  URL+postAndForget.swift
//  BeaconBleTest
//
//  Created by Aaron on 12/13/19.
//  Copyright © 2019 Atomic Robot. All rights reserved.
//

import Foundation

extension URL {
    
    func postAndForget(withBody body: String? = nil, logger: Logger? = nil, completion: @escaping () -> Void = {}) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        //let url = NSURL(string: urlString as String)
        var request : URLRequest = URLRequest(url: self)
        request.httpMethod = "POST"
        request.httpBody = body?.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let dataTask = session.dataTask(with: request) { _, _, _ in
            completion()
        }
        dataTask.resume()

    }
}


