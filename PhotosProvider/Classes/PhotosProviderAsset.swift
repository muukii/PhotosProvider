//
//  PhotosProviderAsset.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import CoreLocation

public func == (lhs: PhotosProviderAsset, rhs: PhotosProviderAsset) -> Bool {
    
    return lhs.localIdentifier == rhs.localIdentifier
}

public protocol PhotosProviderAsset: class {
    
    var localIdentifier: String { get }
    
    var assetMediaType: AssetMediaType { get }
    var pixelWidth: Int { get }
    var pixelHeight: Int { get }
    
    var creationDate: NSDate? { get }
    var modificationDate: NSDate? { get }
    
    var location: CLLocation? { get }
    var duration: NSTimeInterval { get }
    
    var hidden: Bool { get }
    var favoriteAsset: Bool { get }
    
    var originalImageDownloadProgress: NSProgress? { get }
    
    func requestImage(
        targetSize targetSize: CGSize,
        progress: NSProgress? -> Void,
        option: PhotosProviderAssetOption?,
        completion: (PhotosProviderAsset, PhotosProviderAssetResult) -> Void)
    
    func requestOriginalImage(
        progress progress: NSProgress? -> Void,
        option: PhotosProviderAssetOption?,
        completion: (PhotosProviderAsset, PhotosProviderAssetResult) -> Void)
    
    func cancelRequestImage()
    func cancelRequestOriginalImage()
}

public enum AssetMediaType: Int {
    
    case Unknown
    case Image
    case Video
    case Audio
}

extension PHAsset: PhotosProviderAsset {
    
    public var favoriteAsset: Bool {
        
        return self.favorite
    }
    
    public var assetMediaType: AssetMediaType {
        
        return AssetMediaType(rawValue: self.mediaType.rawValue)!
    }
    
    public func requestImage(
        targetSize targetSize: CGSize,
        progress: NSProgress? -> Void,
        option: PhotosProviderAssetOption?,
        completion: (PhotosProviderAsset, PhotosProviderAssetResult) -> Void) {
            
            // TODO: option
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.networkAccessAllowed = true
            options.version = .Current
            options.resizeMode = .Fast
            options.progressHandler = { progress, error, stop, info in
                
                // TODO:
            }
            
            self.imageRequestID = PHImageManager.defaultManager().requestImageForAsset(
                self,
                targetSize: targetSize,
                contentMode: PHImageContentMode.AspectFill,
                options: options) { (image, info) -> Void in
                    
                    guard let image = image else {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(self, .Failure(PhotosProviderAssetResultErrorType.Unknown))
                        }
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(self, .Success(image))
                    }
            }
    }
    
    public func requestOriginalImage(
        progress progress: NSProgress? -> Void,
        option: PhotosProviderAssetOption?,
        completion: (PhotosProviderAsset, PhotosProviderAssetResult) -> Void) {
            
            // TODO: option

            
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.networkAccessAllowed = true
            options.version = .Current
            options.progressHandler = { _progress, error, stop, info in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if self.originalImageDownloadProgress == nil {
                        self.originalImageDownloadProgress = NSProgress(totalUnitCount: 10000)
                        progress(self.originalImageDownloadProgress)
                    }
                    
                    self.originalImageDownloadProgress?.completedUnitCount = Int64(_progress * Double(10000))
                                        
                    if _progress == 1.0 {
                        self.originalImageDownloadProgress = nil
                    }
                }
            }
            
            self.originalImageRequestID = PHImageManager.defaultManager().requestImageForAsset(
                self,
                targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                contentMode: PHImageContentMode.AspectFill,
                options: options) { (image, info) -> Void in
                    
                    guard let image = image else {
                        completion(self, .Failure(PhotosProviderAssetResultErrorType.Unknown))
                        return
                    }
                    
                    completion(self, .Success(image))
            }
    }
    
    public dynamic var originalImageDownloadProgress: NSProgress? {
        
        get {
            
            let value = objc_getAssociatedObject(self, &StoredProperties.originalImageDownloadProgress) as? NSProgress
            return value
        }
        set {
            
            objc_setAssociatedObject(
                self,
                &StoredProperties.originalImageDownloadProgress,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func cancelRequestImage() {
        
        guard let imageRequestID = self.imageRequestID else {
            return
        }
        PHImageManager.defaultManager().cancelImageRequest(imageRequestID)
    }
    
    public func cancelRequestOriginalImage() {
        
        guard let originalImageRequestID = self.originalImageRequestID else {
            return
        }
        PHImageManager.defaultManager().cancelImageRequest(originalImageRequestID)
        self.originalImageDownloadProgress?.cancel()
    }
    
    private var imageRequestID: PHImageRequestID? {
    
        get {
            
            let value = (objc_getAssociatedObject(self, &StoredProperties.imageRequestID) as? NSNumber)?.intValue
            return value
        }
        set {
            
            guard let newValue = newValue else {
                return
            }
            objc_setAssociatedObject(
                self,
                &StoredProperties.imageRequestID,
                NSNumber(int: newValue),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
    private var originalImageRequestID: PHImageRequestID? {
    
        get {
            
            let value = (objc_getAssociatedObject(self, &StoredProperties.originalImageRequestID) as? NSNumber)?.intValue
            return value
        }
        set {
            
            guard let newValue = newValue else {
                return
            }
            objc_setAssociatedObject(
                self,
                &StoredProperties.originalImageRequestID,
                NSNumber(int: newValue),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
    private struct StoredProperties {
        
        static var originalImageDownloadProgress: Void?
        static var imageRequestID: Void?
        static var originalImageRequestID: Void?
    }
}
