//  MGTesterLogging.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/4/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import Foundation

public struct MGRedmineLogging {
    
    static var lastestAPIInfo: String {
        return deviceInfo + apiURL + method + apiParams + responseCode + response + "\n\n"
    }
    
    static var deviceInfo: String = "" {
        didSet {
            deviceInfo = "\n" + "*Device Info:* \n\n" + "<pre><code>\(deviceInfo)</code></pre>" + "\n\n"
        }
    }
    
    static var method: String = "" {
        didSet {
            method = "*METHOD:* " + method + "\n\n"
        }
    }
    
    static var apiURL: String = "" {
        didSet {
            apiURL = "*API URL:* " + apiURL + "\n\n"
        }
    }
    
    static var apiParams: String = "" {
        didSet {
            apiParams = "*API PARAMS:* \n\n" + "<pre><code>\(apiParams)</code></pre>" + "\n\n"
        }
    }
    
    static var responseCode: String = "" {
        didSet {
            responseCode = "*CODE:* " + responseCode + "\n\n"
        }
    }
    
    static var response: String = "" {
        didSet {
            response = "*RESPONSE:* \n\n" + "<pre><code>\(response)</code></pre>" + "\n\n"
        }
    }
    
    public static func updateAPIInfo(deviceInfo: String, apiURL: String, apiParams: String, responseCode: String, response: String, method: String) {
        guard MGRedmineManager.sharedInstance.testEnabled else { return }
        self.deviceInfo = deviceInfo
        self.apiURL = apiURL
        self.apiParams = apiParams
        self.responseCode = responseCode
        self.response = response
        self.method = method
    }
}
