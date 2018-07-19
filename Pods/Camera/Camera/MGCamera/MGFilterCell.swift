//
//  MGFilterCell.swift
//  Camera
//
//  Created by Tung Tran on 6/25/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit

final class MGFilterCell: UICollectionViewCell {
    @IBOutlet private weak var filterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterImageView.layer.cornerRadius = 8
        filterImageView.layer.borderWidth = 2
        filterImageView.layer.borderColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha: 0.7).cgColor
        filterImageView.clipsToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            filterImageView.layer.borderColor = isSelected ? UIColor(red:1, green:0.48, blue:0.48, alpha:1).cgColor : UIColor(red:0.75, green:0.75, blue:0.75, alpha:0.7).cgColor
        }
    }
    
    func setup(filter: MGFilterPattern) {
        filter.generateThumbnail { [weak self] (image) in
            self?.filterImageView.image = image
        }
    }
}
