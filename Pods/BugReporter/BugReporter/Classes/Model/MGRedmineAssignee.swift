//
//  MGRedmineAssignee.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 12/8/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MGRedmineAssignee {
    let id: Int
    let name: String
    let role: String
    
    init(json: JSON) {
        self.name = json["user"]["name"].stringValue
        self.id = json["user"]["id"].intValue
        self.role = json["roles"].array?.first?["name"].string ?? "Unknown"
    }
}
