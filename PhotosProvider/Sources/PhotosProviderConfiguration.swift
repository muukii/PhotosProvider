//
//  PhotosProviderConfiguration.swift
//  PhotosProvider
//
//  Created by Muukii on 9/5/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public protocol PhotosProviderConfiguration {
    
    // MARK: iOS8 Photos.framework
    @available(iOS 8.0, *)
    static func fetchAlbums() -> [PHAssetCollection]
    
    @available(iOS 8.0, *)
    static func fetchAllPhotosOptions() -> PHFetchOptions
    
    // MARK: iOS7 AssetsLibrary.framework
    
    // TODO:
}

public extension PhotosProviderConfiguration {
    
    @available(iOS 8.0, *)
    static func fetchAlbums() -> [PHAssetCollection] {
        
        var collections: [PHAssetCollection] = []
        
        do {
            let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
            
            topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.insert(collection, atIndex: 0)
                }
            }
        }
        
        do {
            let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
            
            smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.insert(collection, atIndex: 0)
                }
            }
        }
        
        do {
            let albumsResult = PHAssetCollection.fetchAssetCollectionsWithType(
                PHAssetCollectionType.Album,
                subtype: PHAssetCollectionSubtype.Any,
                options: nil)
            
            
            albumsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    collections.insert(collection, atIndex: 0)
                }
            }
        }
        return collections
    }
    
    @available(iOS 8.0, *)
    static func fetchAllPhotosOptions() -> PHFetchOptions {
        
        return PHFetchOptions()
    }
}

