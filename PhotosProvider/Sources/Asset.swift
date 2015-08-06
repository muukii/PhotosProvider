//
//  Asset.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary
import CoreLocation

public protocol Asset {
    
    var assetMediaType: AssetMediaType { get }
    var pixelWidth: Int { get }
    var pixelHeight: Int { get }
    
    var creationDate: NSDate? { get }
    var modificationDate: NSDate? { get }
    
    var location: CLLocation? { get }
    var duration: NSTimeInterval { get }
    
    var hidden: Bool { get }
    var favorite: Bool { get }
    
    func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?)
}

public enum AssetMediaType: Int {
    
    case Unknown
    case Image
    case Video
    case Audio
}

@available(iOS 8.0, *)
extension PHAsset: Asset {
    
    public var assetMediaType: AssetMediaType {
        
        return AssetMediaType(rawValue: self.mediaType.rawValue)!
    }
    
    public func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        PHImageManager.defaultManager().requestImageForAsset(self, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            result?(image: image)
            return
        }
    }
}

extension ALAsset: Asset {
    
    public var assetMediaType: AssetMediaType {
        
        // TODO:
        return .Unknown
    }
    
    public var pixelWidth: Int {
        
        return Int(self.defaultRepresentation().dimensions().width)
    }
    public var pixelHeight: Int {
        
        return Int(self.defaultRepresentation().dimensions().height)
    }
    
    public var creationDate: NSDate? {
        
        return self.valueForProperty(ALAssetPropertyDate) as? NSDate
    }
    
    public var modificationDate: NSDate? {
        
        return self.valueForProperty(ALAssetPropertyDate) as? NSDate
    }
    
    public var location: CLLocation? {
        
        return self.valueForProperty(ALAssetPropertyLocation) as? CLLocation
    }
    
    public var duration: NSTimeInterval {
        
        return (self.valueForProperty(ALAssetPropertyDuration) as! NSNumber).doubleValue
    }
    
    public var hidden: Bool {
        
        // TODO:
        return false
    }
    
    public var favorite: Bool {
        
        // TODO:
        return false
    }
    
    public func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        let cgimage = self.defaultRepresentation().fullScreenImage()
        let image = UIImage(CGImage: cgimage.takeUnretainedValue())
        result?(image: image)
    }
}