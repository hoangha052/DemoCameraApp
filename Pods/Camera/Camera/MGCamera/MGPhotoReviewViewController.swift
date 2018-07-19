//
//  MGPhotoReviewViewController.swift
//  Camera
//
//  Created by Ha Ho on 7/4/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit

class MGPhotoReviewViewController: UIViewController {
    
    @IBOutlet private weak var rightBarButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var filtersView: UIView!
    @IBOutlet private weak var collectionView: FilterCollectionView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var filterViewBottomConstraint: NSLayoutConstraint!
    weak var cameraController: MGCameraViewController?
    var imagePhoto: UIImage!
    var selectedIndexPath: IndexPath!
    static var instantiateViewController: MGPhotoReviewViewController {
        return MGPhotoReviewViewController(nibName: "MGPhotoReviewViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupUI() {
        setupFiltersView()
        applyFilter(index: selectedIndexPath.row)
    }
    
    private func applyFilter(index: Int) {
        FilterManager.sharedInstance.filterPatterns[index].applyFilter(image: imagePhoto) { (filterImage) in
            self.previewImageView.image = filterImage
        }
    }
    
    private func setupFiltersView() {
        collectionView.register(UINib(nibName: String(describing: MGFilterCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MGFilterCell.self))
        toggleFilterView(isHidden: true, animated: false)
        self.collectionView.reloadData()
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private func toggleFilterView(isHidden: Bool, animated: Bool) {
        self.filtersView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.filterViewBottomConstraint.constant = isHidden ? -self.filtersView.frame.size.height : 8
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.filtersView.isHidden = isHidden
            self.filterButton.isSelected = !isHidden
        })
    }
    
    // MARK: - IBAction
    
    @IBAction func rightBarButtonClicked(_ sender: Any) {
        //TODO Test code
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        guard let image = previewImageView.image else { return }
        guard let cameraVC = cameraController else { return }
        dismiss(animated: true) {
            cameraVC.delegate?.cameraController(cameraController: cameraVC, didSelectImage: image)
        }
    }
    
    @IBAction func stickerButtonClicked(_ sender: Any) {
    }
    
    @IBAction func filterButtonClicked(_ sender: Any) {
         toggleFilterView(isHidden: !filtersView.isHidden, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension MGPhotoReviewViewController: FilterCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.applyFilter(index: indexPath.row)
    }
}

