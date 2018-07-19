//
//  MGRedmineAPI.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/10/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import Foundation
import SwiftyJSON
import PKHUD

final class MGRedmineAPI {
    
    private enum MGRedmineIssueTracker: Int {
        case feature = 0
        case bug = 1
        case support = 2
        case refactor = 3
        case chore = 4
    }
    
    private enum MGRedmineStatus: Int {
        case new = 1
    }
    
    private static func uploadIssue(params: [String: AnyObject]) {
        let url = MGRedmineConstants.redmineURL + "/issues.json"
        var params = params
        params["tracker_id"] = MGRedmineIssueTracker.bug.rawValue as AnyObject
        params["status_id"] = MGRedmineStatus.new.rawValue as AnyObject
        if MGRedmineIssue.shared.parentTaskID != 0 {
            params["parent_issue_id"] = MGRedmineIssue.shared.parentTaskID as AnyObject
        }
        if MGRedmineIssue.shared.assignee.id != 0 {
            params["assigned_to_id"] = MGRedmineIssue.shared.assignee.id as AnyObject
        }
        let encodedParams = [
            "issue": params as AnyObject
        ]
        HUD.show(.progress)
        MGRedmineNetwork.requestAPI(method: .post, urlString: url, params: encodedParams) { (_ , error) in
            HUD.hide()
            if let error = error {
                MGRedmineAlert.show(message: error.localizedDescription)
                return
            }
            MGRedmineAlert.show(message: "Post Successfully")
        }
    }
    
    static func uploadIssueWithImage(image: UIImage, params: [String: AnyObject]) {
        let url = MGRedmineConstants.redmineURL + "/uploads.json"
        var encodedParams = params
        HUD.show(.progress)
        MGRedmineNetwork.requestAPI(method: .post, urlString: url, screenshot: image) { (json, error) in
            HUD.hide()
            if let error = error {
                MGRedmineAlert.show(message: error.localizedDescription)
                return
            }
            guard let token = json["upload"]["token"].string else { return }
            let uploadParams = ["token": token, "filename": "image.jpeg", "content_type": "image/jpeg"]
            encodedParams["uploads"] = [uploadParams] as AnyObject
            MGRedmineAPI.uploadIssue(params: encodedParams)
        }
    }
    
    
    static func fetchProjectID(completion: @escaping (Int?) -> Void) {
        let projectName = MGRedmineManager.sharedInstance.projectName
        fetchAllProjects { (json) in
            guard let json = json else { completion(nil); return }
            let projects = json["projects"].arrayValue
            for project in projects {
                if project["name"].stringValue == projectName {
                    completion(project["id"].intValue)
                }
            }
        }
    }
    
    private static func fetchAllProjects(completion: @escaping (JSON?) -> Void) {
        let url = MGRedmineConstants.redmineURL + "/projects.json"
        HUD.show(.progress)
        MGRedmineNetwork.requestAPI(urlString: url) { (json, error) in
            HUD.hide()
            if error != nil {
                completion(nil)
                return
            }
            completion(json)
        }
    }
    
    static func fetchParentTasks(projectID: Int, offset: Int, completion: @escaping ([MGRedmineTask]?)->()) {
        let url = MGRedmineConstants.redmineURL + "/issues.json"
        var params = [
            "project_id": "\(projectID)",
            "offset": offset,
            "limit": MGRedmineConstants.itemsPerPage
            ] as [String: AnyObject]
        let filteredParams = getFilteredParams(keyword: "({QC - IOS}) ~ ({QC - Regression})")
        for (key, value) in filteredParams {
            params[key] = "\(value)" as AnyObject
        }
        
        MGRedmineNetwork.requestAPI(urlString: url, params: params) { (json, error) in
            if let error = error {
                MGRedmineAlert.show(message: error.localizedDescription)
                completion(nil)
                return
            }
            guard let jsonArray = json["issues"].array else { return }
            let tasksArray = jsonArray.map({ MGRedmineTask(json: $0) })
            completion(tasksArray)
        }
    }
    
    private static func getFilteredParams(keyword: String) -> [String: String] {
        return [
            "set_filter": "1",
            "f[]": "subject",
            "v[subject][]": keyword,
            "op[subject]": "^"
        ]
    }
    
    static func validateUser(username: String, password: String, completion: @escaping (String?) -> ()) {
        guard let url = MGRedmineConstants.redmineAuthURL(username, password) else { completion(nil); return}
        HUD.show(.progress)
        MGRedmineNetwork.requestAPI(urlString: url) { (json, error) in
            HUD.hide()
            if error != nil {
                completion(nil)
                return
            }
            completion(json["user"]["api_key"].string)
        }
    }
    
    static func fetchAssignees(projectID: Int, offset: Int, completion: @escaping ([MGRedmineAssignee]?)->()) {
        let url = MGRedmineConstants.redmineURL + "/projects/\(MGRedmineIssue.shared.projectID)/memberships.json"
        let params = [
            "limit": MGRedmineConstants.itemsPerPage,
            "offset": offset
        ] as [String: AnyObject]
        MGRedmineNetwork.requestAPI(urlString: url, params: params) { (json, error) in
            if let error = error {
                MGRedmineAlert.show(message: error.localizedDescription)
                completion(nil)
                return
            }
            guard let jsonArray = json["memberships"].array, jsonArray.count > 0 else { completion([MGRedmineAssignee]()); return }
            let assigneesArray = jsonArray.map({ MGRedmineAssignee(json: $0) })
            completion(assigneesArray)
        }
    }
}
