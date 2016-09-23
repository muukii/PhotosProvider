//
//  Collection.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public func == (lhs: PhotosProviderCollection, rhs: PhotosProviderCollection) -> Bool {
    
    return lhs === rhs
}

open class PhotosProviderCollection: Hashable {
    
    open private(set) var title: String
    
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
    
    public init(title: String, sourceCollection: PHAssetCollection, configuration: PhotosProviderConfiguration, buildGroupByDay: Bool = false) {
        
        self.title = title
        self.configuration = configuration
        self.sourceCollection = sourceCollection
    }
    
    open func cancelRequestGroup() {
        
        currentReuqestGroupOperation?.cancel()
    }
        
    open func requestGroup(refetch: Bool = false, completion: @escaping (_ group: PhotosProviderAssetsGroup) -> Void) {
        
        if let group = group, refetch == false {
            completion(group)
            return
        }
        
        let operation = BlockOperation {
            guard let collection = self.sourceCollection as? PHAssetCollection else {
                assert(false, "sourceCollection is not PHAssetCollection")
                return
            }
            let fetchOptions = self.configuration.fetchPhotosOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            let _assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            let assetGroup = AssetGroup(fetchResult: _assets)
            self.group = assetGroup
            
            DispatchQueue.main.async {
                completion(assetGroup)
            }
        }
        
        currentReuqestGroupOperation = operation
        PhotosProviderCollection.operationQueue.addOperation(operation)
    }
    
    open func requestGroupByDay(refetch: Bool = false, completion: @escaping (_ groupByDay: PhotosProviderAssetsGroupByDay) -> Void) {
        
        if let groupByDay = groupByDay, refetch == false {
            completion(groupByDay)
            return
        }
        
        requestGroup(refetch: refetch) { [weak self] group in
            group.requestAssetsGroupByDays { _groupByDay in
                
                self?.groupByDay = _groupByDay
                completion(_groupByDay)
            }
        }
    }
    
    private var groupByDay: PhotosProviderAssetsGroupByDay?
    private var group: PhotosProviderAssetsGroup?
    private var sourceCollection: AnyObject?
    private var configuration: PhotosProviderConfiguration
    
    open var hashValue: Int {
        
        return ObjectIdentifier(self).hashValue
    }
    
    private var currentReuqestGroupOperation: Operation?
    
    private static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
}
