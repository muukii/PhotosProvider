// PhotosPickerCollection.swift
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

import Foundation
import Photos

public class PhotosPickerCollectionsItem {
    
    public private(set) var title: String
    public private(set) var numberOfAssets: Int
    public var assets: PhotosPickerAssets {
        didSet {
            
            self.cachedDividedAssets = nil
            self.cachedTopImage = nil
        }
    }
    
    public func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?) {
        
        if let dividedAssets = self.cachedDividedAssets {
            
            result?(dividedAssets: dividedAssets)
            return
        }
        
        self.assets.requestDividedAssets { (dividedAssets) -> Void in
            
            self.cachedDividedAssets = dividedAssets
            result?(dividedAssets: dividedAssets)
        }
        
    }
    
    public func requestTopImage(result: ((image: UIImage?) -> Void)?) {
        
        if let image = self.cachedTopImage {
            
            result?(image: image)
            return
        }
        
        
        self.requestDividedAssets { (dividedAssets) -> Void in
            
            if let topAsset: PhotosPickerAsset = dividedAssets.first?.assets.first {
                
                topAsset.requestImage(CGSize(width: 100, height: 100), result: { (image) -> Void in
                    
                    self.cachedTopImage = image
                    result?(image: image)
                    return
                })
            }
        }
        
    }
    
    public init(title: String, numberOfAssets: Int, assets: PhotosPickerAssets) {
        
        self.title = title
        self.numberOfAssets = numberOfAssets
        self.assets = assets        
    }
    
    // TODO: Cache
    private var cachedTopImage: UIImage?
    private var cachedDividedAssets: DividedDayPhotosPickerAssets?
}