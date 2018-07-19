//
//  MGRedmineLoginViewController.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/27/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import UIKit

class MGRedmineLoginViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onViewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        guard let username = usernameLabel.text, let password = passwordLabel.text,
            username.trimmingCharacters(in: .whitespaces).count != 0 && password.trimmingCharacters(in: .whitespaces).count != 0 else {
                MGRedmineAlert.show(message: "Please fill in username and password!") ;return }
        MGRedmineAPI.validateUser(username: username, password: password) { (apiKey) in
            guard let apiKey = apiKey else { MGRedmineAlert.show(message: "Are you sure you enter the correct username/password?"); return }
            MGRedminePersistence.saveString(value: apiKey, key: .apiKey)
            MGRedminePersistence.saveString(value: username, key: .username)
            self.dismiss(animated: true) {
                MGRedmineNavigation.presentRedmineBoard()
            }
        }
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
