//
//  MGRedmineTask.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 11/15/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import SwiftyJSON
import Async

struct MGRedmineTask {
    let id: Int
    let subject: String
    let author: String
    let createdOn: Date
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.author = json["author"]["name"].stringValue
        self.subject = "#\(self.id) \(json["subject"].stringValue)"
        self.createdOn = json["created_on"].dateValue ?? Date()
    }
}

