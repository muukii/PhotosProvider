//
//  PhotosProvider.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

public enum PhotosProviderAuthorizationStatus : Int {
    
    case NotDetermined // User has not yet made a choice with regards to this application
    case Restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    case Denied // User has explicitly denied this application access to photos data.
    case Authorized // User has authorized this application to access photos data.
}

func PPLog<T>(value: T) {
    #if DEBUG
        print(value, appendNewline: true)
    #else
    #endif
}

public struct PhotosProvider {
    
    public static var authorizationStatus: PhotosProviderAuthorizationStatus {
        
        if #available(iOS 8.0, *) {
            
            return PhotosProviderAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!
        } else {
            
            return PhotosProviderAuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
        }
    }
    
    public static func requestAuthorization(handler: ((PhotosProviderAuthorizationStatus) -> Void)?) {
        
        if #available(iOS 8.0, *) {
            
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                let status = PhotosProviderAuthorizationStatus(rawValue: status.rawValue)!
                handler?(status)
            })
        } else {
            
            // TODO:
        }
    }
    
    public static func startPreheating() {
        
    }
    
    public static func endPreheating() {
        
    }
    
    @available(iOS 8.0, *)
    public static func fetchAllPhotos(options: PHFetchOptions? = nil) -> Collection {
        let defaultOptions: PHFetchOptions = {
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            return options
        }()
        let fetchResult = PHAsset.fetchAssetsWithOptions(options ?? defaultOptions)
        
        let collection = Collection(title: "カメラロール", group: fetchResult)
        return collection
    }
    
    @available(iOS 8.0, *)
    public static func fetchAllAlbums() -> [Collection] {
        
        let collections = self.fetchAssetCollection()
        let defaultOptions: PHFetchOptions = {
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            return options
            }()
        return collections.map {
            
            let _assets = PHAsset.fetchAssetsInAssetCollection($0, options: defaultOptions)
            let title = $0.localizedTitle ?? ""
            return Collection(title: title, group: _assets)
        }        
    }
    
    @available(iOS 8.0, *)
    public static func fetchTopLevelUserCollections() -> [PHAssetCollection] {
        
        let topLevelUserCollectionsResult: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        
        var collections: [PHAssetCollection] = []
        topLevelUserCollectionsResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
            
            if let collection = collection as? PHAssetCollection {
                collections.insert(collection, atIndex: 0)
            }
        }
        return collections
    }
    
    @available(iOS 8.0, *)
    public static func fetchSmartAlbumsCollections() -> [PHAssetCollection] {
        
        let smartAlbumsCollectionResult: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.Any, options: nil)
        var collections: [PHAssetCollection] = []
        
        smartAlbumsCollectionResult.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
            
            if let collection = collection as? PHAssetCollection {
                collections.insert(collection, atIndex: 0)
            }
        }
        return collections
    }
            
    @available(iOS 8.0, *)
    public static func fetchAssetCollection() -> [PHAssetCollection] {
        
        let collections: [PHAssetCollection] = self.fetchTopLevelUserCollections() + self.fetchSmartAlbumsCollections()
        
        return collections
    }
    
    
}