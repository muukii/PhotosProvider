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
    func fetchAlbums() -> [PHAssetCollection]
    
    @available(iOS 8.0, *)
    func fetchPhotosOptions() -> PHFetchOptions
    
    // MARK: iOS7 AssetsLibrary.framework
    
    // TODO:
}

public extension PhotosProviderConfiguration {
    
    @available(iOS 8.0, *)
    func fetchAlbums() -> [PHAssetCollection] {
        
        var albumCollections: [PHAssetCollection] = []
        do {
            let albumsResult = PHAssetCollection.fetchAssetCollectionsWithType(
                PHAssetCollectionType.Album,
                subtype: PHAssetCollectionSubtype.Any,
                options: nil)
            
            
            albumsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    albumCollections.insert(collection, atIndex: 0)
                }
            }
        }
        
        var topLevelCollections: [PHAssetCollection] = []
        do {
            let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
            
            topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    topLevelCollections.append(collection)
                }
            }
        }
        let userLibraryCollection: PHAssetCollection = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary, options: nil).firstObject as! PHAssetCollection
        
        var smartCollections: [PHAssetCollection] = []
        do {
            let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
            
            smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection where collection != userLibraryCollection {
                    smartCollections.append(collection)
                }
            }
        }
        
        return [userLibraryCollection] + smartCollections + topLevelCollections + albumCollections
    }
    
    @available(iOS 8.0, *)
    func fetchPhotosOptions() -> PHFetchOptions {
        
        return PHFetchOptions()
    }
}

struct PhotosProviderDefaultConfiguration: PhotosProviderConfiguration {
    
}
