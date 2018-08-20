//
//  MGFilterPattern.swift
//  Camera
//
//  Created by Tung Tran on 6/25/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import Foundation
import UIKit

internal func imageFromBundle(_ named: String) -> UIImage {
    return UIImage(named: named, in: Bundle(for: MGFilterPattern.self), compatibleWith: nil) ?? UIImage()
}

final class MGFilterPattern {
    let patternImage: UIImage?

    private var thumbnailImage: UIImage?
    
    init(patternImage: UIImage?) {
        self.patternImage = patternImage
    }
    
    func generateThumbnail(completion: @escaping (UIImage) -> Void) {
        if let thumbnailImage = thumbnailImage {
            completion(thumbnailImage)
            return
        }
        
        applyFilter(image: imageFromBundle("thumb")) { [weak self] (image) in
            self?.thumbnailImage = image
            completion(image)
        }
    }
    
    func applyFilter(image: UIImage, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let patternImage = self.patternImage,
                let lookupFilter = MGLookupFilter(lookupImage: patternImage)
            else {
                DispatchQueue.main.async {
                    completion(image)
                }
                return
            }
            let filterdImage = lookupFilter.image(byFilteringImage: image) ?? image
            DispatchQueue.main.async {
                completion(filterdImage)
            }
        }
    }
}
