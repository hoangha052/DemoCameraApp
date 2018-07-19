//
//  MGRedmineNetworkManager.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/12/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import Foundation
import SwiftyJSON
import Async

final class MGRedmineNetwork {
    
    static func requestAPI(method: MGNetworkMethod = .get, urlString: String, params: [String: AnyObject]? = nil, screenshot: UIImage? = nil, completion: @escaping (JSON, NSError?) -> Void) {
        MGBugReporterNetwork.requestAPI(method: method, urlString: urlString, params: params, screenshot: screenshot) { (json, response, error) in
            guard error == nil else { completion(json, error); return }
            if let response = response {
                if [200, 201].contains(response.statusCode) {
                    completion(json, nil)
                    return
                }
                completion(JSON(), NSError(domain: MGRedmineManager.sharedInstance.projectName, code: response.statusCode, userInfo: nil))
            }
            completion(JSON(), NSError(domain: MGRedmineManager.sharedInstance.projectName, code: 404, userInfo: nil))
        }
    }
}
