//
//  MGRedmineIssue.swift
//  TwineUITests
//
//  Created by Nguyen Duc Gia Bao on 10/30/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct MGRedmineIssue {
    var subject = ""
    var description = ""
    var priority = MGRedminePriority.urgent
    var parentTaskID = 0
    var projectID = 0
    var assignee = MGRedmineAssignee(json: [:])
    var screenshot = UIImage()
    static var shared =  MGRedmineIssue()
    
    static func initProjectID() {
        if let projectID = MGRedminePersistence.getInt(key: .projectID) {
            shared.projectID = projectID
            return
        }
        MGRedmineAPI.fetchProjectID { (projectID) in
            guard let projectID = projectID else { MGRedmineAlert.show(message: "Cannot find project!"); return }
            MGRedminePersistence.saveInt(value: projectID, key: .projectID)
            shared.projectID = projectID
        }
    }
    
    static func resetData() {
        shared = MGRedmineIssue()
    }
}
