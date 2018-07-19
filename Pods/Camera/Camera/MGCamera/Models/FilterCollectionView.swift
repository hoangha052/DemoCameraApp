//
//  FilterCollectionView.swift
//  Camera
//
//  Created by Ha Ho on 7/16/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit

protocol FilterCollectionViewDelegate: class {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

class FilterCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    weak var collectionViewDelegate: FilterCollectionViewDelegate?
    
    func setupFiltersView() {
        self.register(UINib(nibName: String(describing: MGFilterCell.self), bundle: Bundle(for: MGFilterCell.self)), forCellWithReuseIdentifier: String(describing: MGFilterCell.self))
        self.delegate = self
        self.dataSource = self
        self.reloadData()
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterManager.sharedInstance.filterPatterns.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MGFilterCell.self), for: indexPath) as? MGFilterCell else { return UICollectionViewCell() }
        cell.setup(filter: FilterManager.sharedInstance.filterPatterns[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionViewDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}
