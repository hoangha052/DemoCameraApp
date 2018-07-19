//
//  ViewController.swift
//  DemoCameraApp
//
//  Created by Ha Ho on 7/19/18.
//  Copyright © 2018 Ha Ho. All rights reserved.
//

import UIKit
import Camera
import AVKit

class ViewController: UIViewController {
@IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction private func cameraButtonTapped(_ sender: UIButton) {
        let vc = MGCameraViewController.instantiateViewController
        vc.delegate = self
        vc.modalTransitionStyle = .coverVertical
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        present(naviVC, animated: true, completion: nil)
    }

}

extension ViewController: MGCameraViewControllerDelegate {
    func cameraController(cameraController: MGCameraViewController, didSelectImage image: UIImage) {
        UIView.transition(with: imageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.imageView.image = image
        }, completion: nil)
    }
    
    func cameraController(cameraController: MGCameraViewController, didSelectVideo videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true, completion: nil)
    }
}
