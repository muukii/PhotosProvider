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
    
    var didChange: (() -> Void)?
    
    private(set) var isObserving: Bool = false
    
    func startObserving() {
        
        self.isObserving = true
        
        if #available(iOS 8.0, *) {
            
            //            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        } else {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "assetsLibraryDidChange:", name: ALAssetsLibraryChangedNotification, object: nil)
        }
    }
    
    func endObserving() {
        
        self.isObserving = false
        
        if #available(iOS 8.0, *) {
            
            //            PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
        } else {
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    private dynamic func assetsLibraryDidChange(notification: NSNotification) {
        
        self.didChange?()
    }
}

//extension PhotosPickerLibraryObserver: PHPhotoLibraryChangeObserver {
//
//    func photoLibraryDidChange(changeInstance: PHChange) {
//        //
//        }
//}
