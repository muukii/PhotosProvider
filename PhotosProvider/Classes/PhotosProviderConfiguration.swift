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
    
    func fetchAlbums() -> [PHAssetCollection]
    func fetchPhotosOptions() -> PHFetchOptions
}

public extension PhotosProviderConfiguration {
    
    func fetchAlbums() -> [PHAssetCollection] {
        
        var albumCollections: [PHAssetCollection] = []
        do {
            let albumsResult = PHAssetCollection.fetchAssetCollections(
                with: PHAssetCollectionType.album,
                subtype: PHAssetCollectionSubtype.any,
                options: nil)
            
            albumsResult.enumerateObjects({ (collection, index, stop) -> Void in
                
                albumCollections.insert(collection, at: 0)
            })
        }
        
        var topLevelCollections: [PHAssetCollection] = []
        do {
            let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            
            topLevelUserCollectionsResult.enumerateObjects({ (collection, index, stop) -> Void in
                
                if let collection = collection as? PHAssetCollection {
                    topLevelCollections.append(collection)
                }
            })
        }
        let userLibraryCollection: PHAssetCollection = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: nil).firstObject!
        
        var smartCollections: [PHAssetCollection] = []
        do {
            let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
            
            smartAlbumsCollectionResult.enumerateObjects({ (collection, index, stop) -> Void in
                
                if collection != userLibraryCollection {
                    smartCollections.append(collection)
                }
            })
        }
        
        return [userLibraryCollection] + smartCollections + topLevelCollections + albumCollections
    }
    
    func fetchPhotosOptions() -> PHFetchOptions {
        
        return PHFetchOptions()
    }
}

struct PhotosProviderDefaultConfiguration: PhotosProviderConfiguration {
    
}
