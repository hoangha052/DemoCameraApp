//
//  MGPreviewViewController.swift
//  BugReporter
//
//  Created by Nguyen Duc Gia Bao on 11/22/17.
//  Copyright © 2017 com.mingle.bugreporter. All rights reserved.
//

import UIKit

final class MGPreviewViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    deinit {
        MGRedmineIssue.resetData()
    }
    
    private func configureUI() {
        imageView.image = MGRedmineIssue.shared.screenshot
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func presentActionSheet(title: String) {
        guard let topViewController = UIViewController.topViewController() else { return }
        let alertController = UIAlertController(title: title, message: "Please choose your action", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { _ in
            MGRedmineNavigation.presentRedmineBoard()
        }
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            MGRedminePersistence.remove(key: .apiKey)
            MGRedminePersistence.remove(key: .username)
        }
        alertController.addAction(uploadAction)
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        topViewController.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onImageTapped(_ sender: Any) {
        let editImageViewController = EditImageViewController()
        editImageViewController.screenshot = imageView.image
        let interfaceCustomization = InterfaceCustomization(interfaceText: InterfaceCustomization.InterfaceText(), appearance: InterfaceCustomization.Appearance())
        editImageViewController.delegate = self
        editImageViewController.interfaceCustomization = interfaceCustomization
        let navigationController = UINavigationController(rootViewController: editImageViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNextButtonTapped(_ sender: Any) {
        if let username = MGRedmineManager.sharedInstance.username {
            self.presentActionSheet(title: username)
            return
        }
        MGRedmineNavigation.presentLogin()
    }
}

// MARK: - Editor Delegate
extension MGPreviewViewController: EditorDelegate {
    func editorWillDismiss(_ editor: Editor, with screenshot: UIImage) {
        MGRedmineIssue.shared.screenshot = screenshot
        imageView.image = screenshot
    }
}
