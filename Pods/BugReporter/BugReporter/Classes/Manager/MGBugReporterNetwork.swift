//
//  MGBugReporterNetwork.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 12/4/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation
import SwiftyJSON
import Async

final class MGBugReporterNetwork {
    static func requestAPI(method: MGNetworkMethod = .get, urlString: String, params: [String: AnyObject]? = nil, screenshot: UIImage? = nil, completion: @escaping (JSON, HTTPURLResponse?, NSError?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)
        switch method {
        case .get:
            urlRequest = URLRequest(url: encodeQuery(url: url, params: params) ?? url)
            urlRequest.allHTTPHeaderFields = getHTTPHeaders(method: .get)
        case .post:
            urlRequest = encodeData(urlRequest, method: method, params: params ?? [:], image: screenshot)
            urlRequest.allHTTPHeaderFields = screenshot == nil ? getHTTPHeaders(method: .post) : getHTTPHeaders(method: .post, imageIncluded: true)
        default:
            break
        }
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            Async.main {
                guard let data = data else {
                    completion(JSON([:]), response as? HTTPURLResponse, error as NSError?)
                    return
                }
                completion(JSON(data: data), response as? HTTPURLResponse, error as NSError?)
            }
            }.resume()
    }
    
    private static func getHTTPHeaders(method: MGNetworkMethod, imageIncluded: Bool = false) -> [String: String] {
        var headers = [
            "Authorization": "Basic \(MGRedmineConstants.redmineAPIAuthorizationToken)",
            "X-Redmine-API-Key": MGRedmineManager.sharedInstance.apiKey ?? ""
        ]
        switch method {
        case .get:
            headers["Content-Type"] = "application/json"
        case .post:
            headers["Content-Type"] = imageIncluded ? "application/octet-stream" : "application/json"
        default:
            break
        }
        return headers
    }
    
    private static func encodeData(_ urlRequest: URLRequest, method: MGNetworkMethod, params: [String: AnyObject], image: UIImage?) -> URLRequest {
        var encodedRequest = urlRequest
        if let image = image, let data = UIImagePNGRepresentation(image) {
            encodedRequest.httpBody = data
        } else {
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            encodedRequest.httpBody = jsonData
        }
        encodedRequest.httpMethod = method.rawValue
        return encodedRequest
    }
    
    private static func encodeQuery(url: URL, params: [String: AnyObject]?) -> URL? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        if let params = params {
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: "\(value as AnyObject)"))
            }
            urlComponents.queryItems = queryItems
        }
        return urlComponents.url
    }
}
