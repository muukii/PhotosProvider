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

#if !PHOTOSPROVIDER_EXCLUDE_IMPORT_MODULES
    import GCDKit
#endif

public enum PhotosProviderAuthorizationStatus : Int {
    
    case NotDetermined // User has not yet made a choice with regards to this application
    case Restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    case Denied // User has explicitly denied this application access to photos data.
    case Authorized // User has authorized this application to access photos data.
}

public class PhotosProvider {
    
    public var libraryDidChanged: (() -> Void)?
    
    public let configuration: PhotosProviderConfiguration
    
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
                
                GCDBlock.async(.Main) {
                    handler?(status)
                }
            })
        } else {
            
            // TODO:
        }
    }
    
    public init(configuration: PhotosProviderConfiguration) {
        
        self.configuration = configuration
        self.monitor.startObserving()
        
        if #available(iOS 8.0, *) {
            
            self.monitor.photosDidChange = { [weak self] change in
                
                guard let strongSelf = self else {
                    return
                }
                
                let buildGroupdByDay = strongSelf.cachedBuildGroupByDay ?? false
                
                strongSelf.cachedFetchedAlbums = nil
                self?.fetchAlbums(buildGroupByDay: buildGroupdByDay) { _ in
                    
                    GCDBlock.async(.Main) {
                        self?.libraryDidChanged?()
                    }
                }
            }
        } else {
            
            self.monitor.assetsLibraryDidChange = { notification in
                
            }
        }
    }
    
    public func startPreheating() {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return
        }

        self.fetchAlbums() { result in
            
            // Finish Preheat
        }
    }
    
    public func endPreheating() {
        
    }
    
    public func fetchAllPhotos(result: (PhotosProviderCollection?) -> Void) {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return
        }
        
        if #available(iOS 8.0, *) {
            // Use Photos.framework
            
            GCDBlock.async(queue) {
                
                let options = self.configuration.fetchPhotosOptions()
                options.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false),
                ]
                
                guard let userLibrary = PHAssetCollection.fetchAssetCollectionsWithType(
                    PHAssetCollectionType.SmartAlbum,
                    subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary,
                    options: nil).firstObject as? PHAssetCollection else {
                        return
                }
                
                let fetchResult = PHAsset.fetchAssetsInAssetCollection(userLibrary, options: options)
                
                let collection = PhotosProviderCollection(title: userLibrary.localizedTitle ?? "", group: fetchResult, configuration: self.configuration)
                
                GCDBlock.async(.Main) {
                    
                    result(collection)
                }
            }
            
            
        } else {
            // Use AssetsLibrary.framework
            
            fatalError("Sorry, Not yet supported...")
        }
    }
    
    public func fetchAlbums(buildGroupByDay buildGroupByDay: Bool = false, @noescape result: [PhotosProviderCollection] -> Void) {
        
        guard PhotosProvider.authorizationStatus == .Authorized else {
            return
        }
        
        if let fetchedAlbums = self.cachedFetchedAlbums {
            
            result(fetchedAlbums)
            return
        }
        
        if #available(iOS 8.0, *) {
            
            // Using Photos Framework
            
            let collections = self.configuration.fetchAlbums()
            let fetchOptions = self.configuration.fetchPhotosOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            let albums: [PhotosProviderCollection] = collections.map { collection in
                
                let title = collection.localizedTitle ?? ""
                return PhotosProviderCollection(title: title, sourceCollection: collection, configuration: self.configuration)
            }
            
            self.cachedFetchedAlbums = albums
            self.cachedBuildGroupByDay = buildGroupByDay
        
            result(albums)
        } else {
            
            // Using AssetsLibrary Framework
            
            // TODO:
        }
    }
    
    deinit {
        monitor.endObserving()
    }
    
    private var cachedFetchedAlbums: [PhotosProviderCollection]?
    private var cachedBuildGroupByDay: Bool?
    
    private let queue: GCDQueue = GCDQueue.createSerial("me.muukii.PhotosProvider.queue")
    private let monitor = PhotosProviderMonitor()
}
