//
//  MGRedminePersistence.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/29/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation

final class MGRedminePersistence {
    
    private static let userDefaults = UserDefaults.standard
    
    static func saveInt(value: Int, key: MGRedmineKeys) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    static func saveString(value: String, key: MGRedmineKeys) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    static func remove(key: MGRedmineKeys) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
    static func getInt(key: MGRedmineKeys) -> Int? {
        return userDefaults.value(forKey: key.rawValue) as? Int
    }
    
    static func getString(key: MGRedmineKeys) -> String? {
        return userDefaults.value(forKey: key.rawValue) as? String
    }
}
