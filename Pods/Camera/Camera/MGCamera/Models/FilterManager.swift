//
//  FilterModel.swift
//  Camera
//
//  Created by Ha Ho on 7/17/18.
//  Copyright © 2018 Mingle. All rights reserved.
//

import UIKit

final class FilterManager {
    private init(patterns: [MGFilterPattern]) {
        self.filterPatterns = patterns
    }
    static let sharedInstance: FilterManager = {
       let manager = FilterManager(patterns: getFilterData())
    return manager
    }()
    let filterPatterns: [MGFilterPattern]
    
    private static func getFilterData() -> [MGFilterPattern] {
        var patternData = [MGFilterPattern(patternImage: nil)]
        let fileManager = FileManager.default
        let bundle = Bundle(for: self)
        guard let assetURL =  bundle.url(forResource: "FilterPatternImages", withExtension: "bundle") else {
            print("get URL filter image fail")
            return patternData
        }
        do {
            var contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            contents.sort { $0.lastPathComponent < $1.lastPathComponent
            }
            for itemURL in contents {
                let image = UIImage(data: try Data(contentsOf: itemURL))
                patternData.append(MGFilterPattern(patternImage: image))
            }
        } catch  {
            print("Get filter image fail")
        }
        return patternData
    }
}
