//
//  CIImage+Extensions.swift
//  Camera
//
//  Created by Tung Tran on 6/25/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import Foundation
import CoreImage

extension CIImage {
    func convertToCGImage() -> CGImage? {
        return CIContext(options: nil).createCGImage(self, from: extent)
    }
}
