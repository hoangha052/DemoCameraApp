//
//  LibraryPhotoViewController.swift
//  Camera
//
//  Created by Ha Ho on 7/12/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit
import Photos

class LibraryPhotoViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    private var imagesAsset = [PHAsset]()
    private let cellWidth = (UIScreen.main.bounds.width - 6) / 4
    var cameraMode: CameraMode = .normal
    
    static var libraryPhotoViewController: LibraryPhotoViewController {
        return LibraryPhotoViewController(nibName: "LibraryPhotoViewController", bundle: Bundle(for: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageCollectionView.register(UINib(nibName: String(describing: PhotoCollectionViewCell.self), bundle: Bundle(for: PhotoCollectionViewCell.self)), forCellWithReuseIdentifier: String(describing: PhotoCollectionViewCell.self))
        requestAuthorizationGetData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func requestAuthorizationGetData() {
        /// Load Photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.getAllImages()
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }

    private func getAllImages() {
        let allVidOptions = PHFetchOptions()
        var predecate: NSPredicate
        switch cameraMode {
        case .normal:
            predecate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.video.rawValue, PHAssetMediaType.image.rawValue)
        case .photo:
            predecate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        case .video:
            predecate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        }
        allVidOptions.predicate = predecate
        allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assetResult = PHAsset.fetchAssets(with: allVidOptions)
        assetResult.enumerateObjects { (asset, count, stop) in
            self.imagesAsset.append(asset)
        }
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
    }
    
    private func navigateToPhotoPreViewController(imageAsset: PHAsset) {
        let vc = MGPhotoReviewViewController.instantiateViewController
        vc.imagePhoto = UIImage.convertImageFromAsset(asset: imageAsset, size: PHImageManagerMaximumSize)
        vc.cameraController = self.navigationController?.viewControllers[0] as? MGCameraViewController
        vc.selectedIndexPath = IndexPath(row: 0, section: 0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToVideoPreViewController(videoAsset: PHAsset) {
        let vc = MGVideoPreviewViewController.instantiateViewController
        vc.imagePhoto = UIImage.convertImageFromAsset(asset: videoAsset, size: PHImageManagerMaximumSize)
        vc.selectedIndexPath = IndexPath(row: 0, section: 0)
        vc.cameraViewController = self.navigationController?.viewControllers[0] as? MGCameraViewController
        
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: videoAsset, options: options) { (avasset, audioMix, info) in
            guard let urlAsset = avasset as? AVURLAsset else { return }
            DispatchQueue.main.async {
                vc.videoURL = urlAsset.url
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension LibraryPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCollectionViewCell.self), for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        cell.showImagePhoto(asset: imagesAsset[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetItem = imagesAsset[indexPath.row]
        if assetItem.mediaType == .image {
            self.navigateToPhotoPreViewController(imageAsset: assetItem)
        } else if assetItem.mediaType == .video {
            self.navigateToVideoPreViewController(videoAsset: assetItem)
        }
    }
}
