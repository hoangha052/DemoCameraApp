//
//  MGRedmineNavigationManager.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/27/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import UIKit

final class MGRedmineNavigation {
    
    private static let storyboard = UIStoryboard(name: "MGRedmine", bundle: Bundle(for: MGRedmineManager.self))
    
    static func presentLogin() {
        guard let topViewController = UIViewController.topViewController() else { return }
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "MGRedmineLoginViewController")
        topViewController.present(loginViewController, animated: true, completion: nil)
    }
    
    static func presentPreview() {
        guard let topViewController = UIViewController.topViewController() else { return }
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "MGPreviewViewController") as! MGPreviewViewController
        let navigationController = UINavigationController(rootViewController: previewViewController)
        topViewController.present(navigationController, animated: true, completion: nil)
    }
    
    static func presentRedmineBoard() {
        guard let topViewController = UIViewController.topViewController() else { return }
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        topViewController.present(navigationController, animated: true, completion: nil)
    }
}
