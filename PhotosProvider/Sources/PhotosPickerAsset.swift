// PhotosPickerAsset.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Photos
import AssetsLibrary
import CoreLocation

public protocol PhotosPickerAsset {
    
    var photosObjectMediaType: PhotosPickerAssetMediaType { get }
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

@available(iOS 8.0, *)
extension PHAsset: PhotosPickerAsset {
    
    public var photosObjectMediaType: PhotosPickerAssetMediaType {
        
        return PhotosPickerAssetMediaType(rawValue: self.mediaType.rawValue)!
    }
    
    public func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        PHImageManager.defaultManager().requestImageForAsset(self, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            result?(image: image)
            return
        }
    }
}

extension ALAsset: PhotosPickerAsset {
    
    public var photosObjectMediaType: PhotosPickerAssetMediaType {
        
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
        
        return false
    }
    
    public var favorite: Bool {
        
        return false
    }
    
    public func requestImage(targetSize: CGSize, result: ((image: UIImage?) -> Void)?) {
        
        let cgimage = self.defaultRepresentation().fullScreenImage()
        let image = UIImage(CGImage: cgimage.takeUnretainedValue())
        result?(image: image)
    }
}








