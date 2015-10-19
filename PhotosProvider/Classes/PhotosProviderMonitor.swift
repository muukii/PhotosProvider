//
//  Monitor.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

class PhotosProviderMonitor {
    
    var photosDidChange: ((PhotosProviderChange) -> Void)?
    var assetsLibraryDidChange: ((NSNotification) -> Void)?
    
    private(set) var isObserving: Bool = false
    
    func startObserving() {
        
        self.isObserving = true
        
        if #available(iOS 8.0, *) {
            
            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self.photosLibraryObserver)
        } else {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "assetsLibraryDidChange:", name: ALAssetsLibraryChangedNotification, object: nil)
        }
    }
    
    func endObserving() {
        
        self.isObserving = false
        
        if #available(iOS 8.0, *) {
            
            PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self.photosLibraryObserver)
        } else {
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    private dynamic func assetsLibraryDidChange(notification: NSNotification) {
        
        self.assetsLibraryDidChange?(notification)
    }
    
    @available(iOS 8.0, *)
    private lazy var photosLibraryObserver: PhotosLibraryObserver = { [weak self] in
        let observer = PhotosLibraryObserver()
        observer.didChange = { change in
            
            self?.photosDidChange?(change)
        }
        return observer
    }()
}

protocol PhotosProviderChange {}
@available(iOS 8.0, *)
extension PHChange: PhotosProviderChange {}

@available(iOS 8.0, *)
private class PhotosLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    
    var didChange: ((PHChange) -> Void)?
    @objc private func photoLibraryDidChange(changeInstance: PHChange) {
        
        didChange?(changeInstance)
    }
}
