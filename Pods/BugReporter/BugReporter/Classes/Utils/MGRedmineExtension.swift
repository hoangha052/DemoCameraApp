//
//  MGExt.swift
//  BugReporter
//
//  Created by Tung Tran on 11/20/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation
import UIKit
import Timepiece
import SwiftyJSON

extension UIWindow {
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIViewController {
    static func topViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { return nil }
        return self.topViewControllerFromRoot(rootViewController: rootViewController)
    }
    
    static func topViewControllerFromRoot(rootViewController: UIViewController) -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            guard let selectedViewController = tabBarController.selectedViewController else { return rootViewController }
            return self.topViewControllerFromRoot(rootViewController: selectedViewController)
        } else if let navigationController = rootViewController as? UINavigationController {
            guard let visibleViewController = navigationController.visibleViewController else { return rootViewController }
            return self.topViewControllerFromRoot(rootViewController: visibleViewController)
        } else if let presentedViewController = rootViewController.presentedViewController {
            return self.topViewControllerFromRoot(rootViewController: presentedViewController)
        } else {
            return rootViewController
        }
    }
}

extension Date {
    func timeAgoSinceDate() -> String {
        let now = Date()
        let earliest = now < self ? now : self
        let latest = earliest == now as Date ? self : now
        let timeFormat = DateFormatter()
        timeFormat.locale = NSLocale.current
        
        if latest.year != earliest.year {
            timeFormat.dateFormat = "MMM, yy"
        } else if latest.month != earliest.month {
            timeFormat.dateFormat = "MMM d"
        } else if latest.day != earliest.day {
            timeFormat.dateFormat = "MMM d"
        } else {
            timeFormat.dateFormat = "h:mm a"
            timeFormat.amSymbol = "AM"
            timeFormat.pmSymbol = "PM"
        }
        return timeFormat.string(from: earliest)
    }
}

extension JSON {
    var dateValue: Date? {
        guard let dateString = self.string else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        return date
    }
}
