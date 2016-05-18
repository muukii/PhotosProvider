//
//  Monitor.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos

class PhotosProviderMonitor {
    
    var photosDidChange: ((PhotosProviderChange) -> Void)?
    
    private(set) var isObserving: Bool = false
    
    func startObserving() {
        
        self.isObserving = true
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self.photosLibraryObserver)
    }
    
    func endObserving() {
        
        self.isObserving = false
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self.photosLibraryObserver)
    }
    
    private lazy var photosLibraryObserver: PhotosLibraryObserver = { [weak self] in
        let observer = PhotosLibraryObserver()
        observer.didChange = { change in
            
            self?.photosDidChange?(change)
        }
        return observer
    }()
}

protocol PhotosProviderChange {}
extension PHChange: PhotosProviderChange {}

private class PhotosLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    
    var didChange: ((PHChange) -> Void)?
    @objc private func photoLibraryDidChange(changeInstance: PHChange) {
        
        didChange?(changeInstance)
    }
}
