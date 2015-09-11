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

public class PhotosProvider {
    
    public let configuration: PhotosProviderConfiguration.Type
    
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
    
    public init(configuration: PhotosProviderConfiguration.Type) {
        
        self.configuration = configuration
    }
            
    public func startPreheating() {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return
        }
        // TODO: Auth
        self.fetchAlbums()
    }
    
    public func endPreheating() {
        
    }
    
    public func fetchAllPhotos() -> PhotosProviderCollection? {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return nil
        }
        
        if #available(iOS 8.0, *) {
            // Use Photos.framework
            
            let options = self.configuration.fetchAllPhotosOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            
            guard let userLibrary = PHAssetCollection.fetchAssetCollectionsWithType(
                PHAssetCollectionType.SmartAlbum,
                subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary,
                options: nil).firstObject as? PHAssetCollection else {
                    return nil
            }            
            
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(userLibrary, options: options)

            let collection = PhotosProviderCollection(title: userLibrary.localizedTitle ?? "", group: fetchResult)
            return collection
        } else {
            // Use AssetsLibrary.framework
            
            fatalError("Sorry, Not yet supported...")
        }
    }
    
    public func fetchAlbums(buildGroupByDay buildGroupByDay: Bool = false) -> [PhotosProviderCollection] {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return []
        }
        
        if let fetchedAlbums = self.fetchedAlbums {
            
            return fetchedAlbums
        }
        
        if #available(iOS 8.0, *) {
            
            let collections = self.configuration.fetchAlbums()
            let defaultOptions: PHFetchOptions = {
                let options = PHFetchOptions()
                options.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false),
                ]
                return options
                }()
            let albums: [PhotosProviderCollection] = collections.map {
                
                let _assets = PHAsset.fetchAssetsInAssetCollection($0, options: defaultOptions)
                let title = $0.localizedTitle ?? ""
                return PhotosProviderCollection(title: title, group: _assets, buildGroupByDay: buildGroupByDay)
            }
            
            self.fetchedAlbums = albums
        
            return albums
        } else {
            
            return []
        }
    }
    
    private var fetchedAlbums: [PhotosProviderCollection]?
}
