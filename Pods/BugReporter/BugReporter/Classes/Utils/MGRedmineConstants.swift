//
//  MGRedmineConstants.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/27/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation

internal enum MGRedmineKeys: String {
    case projectID = "MGRedmineProjectID"
    case apiKey = "MGRedmineAPIKey"
    case username = "MGRedmineUsername"
}

internal enum MGNetworkMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

struct MGRedmineConstants {
    static let itemsPerPage = 20
    static let redmineAPIAuthorizationToken = "bWluZ2xlOm1pbmdsZUB3aW4="
    static var redmineURL = "https://redmine.mingle.com"
    static var redmineAuthURL: (String, String) -> String? = {
        return ($0 != "" && $1 != "") ? "https://\($0):\($1)@redmine.mingle.com/users/current.json" : nil
    }
}
