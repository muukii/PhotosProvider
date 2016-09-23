//
//  PhotosProvider.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

public enum PhotosProviderAuthorizationStatus : Int {
    
    case notDetermined // User has not yet made a choice with regards to this application
    case restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    case denied // User has explicitly denied this application access to photos data.
    case authorized // User has authorized this application to access photos data.
}

open class PhotosProvider {
    
    open var libraryDidChanged: (([PhotosProviderCollection]) -> Void)?
    
    open let configuration: PhotosProviderConfiguration
    
    public static var authorizationStatus: PhotosProviderAuthorizationStatus {
        
        return PhotosProviderAuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue)!
    }
    
    public static func requestAuthorization(_ handler: ((PhotosProviderAuthorizationStatus) -> Void)?) {
        
        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            let status = PhotosProviderAuthorizationStatus(rawValue: status.rawValue)!
            
            DispatchQueue.main.async {
                
                handler?(status)
            }
        })
    }
    
    public init(configuration: PhotosProviderConfiguration) {
        
        self.configuration = configuration
        monitor.startObserving()
        
        monitor.photosDidChange = { [weak self] change in
            
            guard let strongSelf = self else {
                return
            }
            
            let buildGroupdByDay = strongSelf.cachedBuildGroupByDay ?? false
            
            strongSelf.cachedFetchedAlbums = nil
            strongSelf.fetchAlbums(buildGroupByDay: buildGroupdByDay) { collections in
                
                DispatchQueue.main.async {
                    
                    self?.libraryDidChanged?(collections)
                }
            }
        }
    }
    
    open func startPreheating() {
        
        guard PhotosProvider.authorizationStatus == .authorized else {
            return
        }

        self.fetchAlbums() { result in
            
            // Finish Preheat
        }
    }
    
    open func endPreheating() {
        
    }
    
    open func fetchAllPhotos(_ result: @escaping (PhotosProviderCollection?) -> Void) {
        
        guard PhotosProvider.authorizationStatus == .authorized else {
            return
        }
        
        queue.async {
            
            let options = self.configuration.fetchPhotosOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false),
            ]
            
            guard let userLibrary = PHAssetCollection.fetchAssetCollections(
                with: PHAssetCollectionType.smartAlbum,
                subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
                options: nil).firstObject else {
                    
                    return
            }
            
            let fetchResult = PHAsset.fetchAssets(in: userLibrary, options: options)
                                    
            let collection = PhotosProviderCollection(title: userLibrary.localizedTitle ?? "", group: AssetGroup(fetchResult: fetchResult), configuration: self.configuration)
            
            DispatchQueue.main.async {
                
                result(collection)
            }
        }
    }
    
    open func fetchAlbums(buildGroupByDay: Bool = false, result: @escaping ([PhotosProviderCollection]) -> Void) {
        
        guard PhotosProvider.authorizationStatus == .authorized else {
            return
        }
        
        if let fetchedAlbums = cachedFetchedAlbums {
            
            result(fetchedAlbums)
            return
        }
        
        queue.async {
            
            let collections = self.configuration.fetchAlbums()
            
            let albums: [PhotosProviderCollection] = collections.map { collection in
                
                let title = collection.localizedTitle ?? ""
                return PhotosProviderCollection(title: title, sourceCollection: collection, configuration: self.configuration)
            }
            
            self.cachedFetchedAlbums = albums
            self.cachedBuildGroupByDay = buildGroupByDay
            
            DispatchQueue.main.async {
                
                result(albums)
            }
        }
    }
    
    deinit {
        monitor.endObserving()
    }
    
    private var cachedFetchedAlbums: [PhotosProviderCollection]?
    private var cachedBuildGroupByDay: Bool?
    
    private let queue = DispatchQueue(label: "me.muukii.PhotosProvider.queue", qos: .default)
    private let monitor = PhotosProviderMonitor()
}
