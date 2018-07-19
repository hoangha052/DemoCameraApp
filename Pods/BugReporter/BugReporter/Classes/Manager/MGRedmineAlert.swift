//
//  MGRedmineAlertManager.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/20/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import Foundation
import UIKit

final class MGRedmineAlert {
    static func show(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelButton)
        guard let topViewController = UIViewController.topViewController() else { return }
        topViewController.present(alertController, animated: true, completion: nil)
    }
}
