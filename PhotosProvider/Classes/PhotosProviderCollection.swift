//
//  Collection.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

#if !PHOTOSPROVIDER_EXCLUDE_IMPORT_MODULES
    import GCDKit
#endif

public func == (lhs: PhotosProviderCollection, rhs: PhotosProviderCollection) -> Bool {
    
    return lhs === rhs
}

public class PhotosProviderCollection: Hashable {
    
    public private(set) var title: String
    
    public init(title: String, group: PhotosProviderAssetsGroup, configuration: PhotosProviderConfiguration, buildGroupByDay: Bool = false) {
        
        self.title = title
        self.configuration = configuration
        self.group = group

        if buildGroupByDay {
            group.requestAssetsGroupByDays { groupByDay in
                self.groupByDay = groupByDay
            }
        }
    }
    
    @available(iOS 8.0, *)
    public init(title: String, sourceCollection: PHAssetCollection, configuration: PhotosProviderConfiguration, buildGroupByDay: Bool = false) {
        
        self.title = title
        self.configuration = configuration
        self.sourceCollection = sourceCollection
    }
    
    public func requestGroup(completion: (group: PhotosProviderAssetsGroup) -> Void) {
        
        if let group = self.group {
            completion(group: group)
        }
        if #available(iOS 8.0, *) {
            
            GCDBlock.async(.Default) {
                
                guard let collection = self.sourceCollection as? PHAssetCollection else {
                    assert(false, "sourceCollection is not PHAssetCollection")
                }
                let fetchOptions = self.configuration.fetchPhotosOptions()
                let _assets = PHAsset.fetchAssetsInAssetCollection(collection, options: fetchOptions)
                self.group = _assets
                
                GCDBlock.async(.Main) {
                    completion(group: _assets)
                }
            }
        } else {
            
        }
    }
    
    public func requestGroupByDay(completion: (groupByDay: PhotosProviderAssetsGroupByDay) -> Void) {
        
        if let groupByDay = self.groupByDay {
            completion(groupByDay: groupByDay)
            return
        }
        
        self.group?.requestAssetsGroupByDays { _groupByDay in
            
            self.groupByDay = _groupByDay
            completion(groupByDay: _groupByDay)
        }
    }
    
    private var groupByDay: PhotosProviderAssetsGroupByDay?
    private var group: PhotosProviderAssetsGroup?
    private var sourceCollection: AnyObject?
    private var configuration: PhotosProviderConfiguration
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self).hashValue
    }
}
