//
//  PHAssetCollection+Util.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

@available(iOS 8.0, *)
extension PHAssetCollection {
    
    func requestNumberOfAssets() -> Int {
        
        let assets = PHAsset.fetchAssetsInAssetCollection(self, options: nil)
        return assets.count
    }
}
