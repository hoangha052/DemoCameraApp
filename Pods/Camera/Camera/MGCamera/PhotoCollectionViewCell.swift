//
//  PhotoCollectionViewCell.swift
//  Camera
//
//  Created by Ha Ho on 7/12/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showImagePhoto(asset: PHAsset) {
        videoView.isHidden = (asset.mediaType == .image)
        if asset.mediaType == .video {
            updateTimerLabel(duration: Int(asset.duration))
        }
        photoImageView.image = UIImage.convertImageFromAsset(asset: asset, size: self.frame.size)
    }
    
    func updateTimerLabel(duration: Int) {
        let hours = duration / 3600
        let minutes = duration / 60 % 60
        let seconds = duration % 60
        videoTimeLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

extension UIImage {
    static func convertImageFromAsset(asset: PHAsset, size: CGSize) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return image
    }
}
