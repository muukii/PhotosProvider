//
//  PHAssetCollection+Util.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

extension PHAssetCollection {
    
    func requestNumberOfAssets() -> Int {
        
        let assets = PHAsset.fetchAssets(in: self, options: nil)
        return assets.count
    }
}
