//
//  MGRedmineManager.swift
//  Niche
//
//  Created by Nguyen Duc Gia Bao on 10/16/17.
//  Copyright © 2017 Mingle. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
//import CLImageEditor

enum MGRedminePriority: Int {
    case low = 0
    case normal = 1
    case high = 2
    case urgent = 3
    case immediate = 4
}

enum MGRedmineDetailType {
    case priority, task, assignee
}

public final class MGRedmineManager: NSObject {
    
    private(set) static var sharedInstance = MGRedmineManager()
    
    internal var apiKey: String? {
        return MGRedminePersistence.getString(key: .apiKey)
    }
    
    internal var username: String? {
        return MGRedminePersistence.getString(key: .username)
    }
    
    internal var projectName = ""
    internal var testEnabled = false
    
    internal convenience init(projectName: String, testEnabled: Bool) {
        self.init()
        self.projectName = projectName
        self.testEnabled = testEnabled
        guard self.testEnabled else { return }
        self.observer()
    }
    
    private func observer() {
        NotificationCenter.default.addObserver(forName: .UIApplicationUserDidTakeScreenshot, object: nil, queue: .main) { (notification) in
            guard let screenShot = UIApplication.shared.keyWindow?.capture() else { return }
            MGRedmineIssue.shared.screenshot = screenShot
            MGRedmineNavigation.presentPreview()
        }
    }
    
    public static func setup(projectName: String, testEnabled: Bool) {
        sharedInstance = MGRedmineManager(projectName: projectName, testEnabled: testEnabled)
        IQKeyboardManager.sharedManager().enable = true
    }
}
