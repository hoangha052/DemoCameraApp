//
//  NguocNangFilter.swift
//  GPUImageLookupFilter
//
//  Created by Thanh Nguyen on 6/19/18.
//  Copyright © 2018 Thanh Nguyen. All rights reserved.
//

import UIKit
import GPUImage

class MGLookupFilter: GPUImageFilterGroup {
    private var lookupImageSource: GPUImagePicture?
    init?(lookupImage: UIImage) {
        super.init()
        guard let lookupImageSource = GPUImagePicture(image: lookupImage) else { return nil }
        self.lookupImageSource = lookupImageSource
        let lookupFilter = GPUImageLookupFilter()
        self.addFilter(lookupFilter)
        lookupImageSource.addTarget(lookupFilter, atTextureLocation: 1)
        lookupFilter.useNextFrameForImageCapture()
        lookupImageSource.processImage()
        lookupImageSource.forceProcessing(at: lookupImageSource.outputImageSize())

        self.initialFilters = [lookupFilter]
        self.terminalFilter = lookupFilter
    }
}
