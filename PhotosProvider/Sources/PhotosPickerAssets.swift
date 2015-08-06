// PhotosPickerAssets.swift
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

public protocol PhotosPickerAssets {
    
    func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?)
    func enumerateAssetsUsingBlock(block: ((asset: PhotosPickerAsset) -> Void)?)
}

public class PhotosPickerAssetsGroup: PhotosPickerAssets {
    
    public private(set) var assets : [PhotosPickerAsset] = []
    
    public init(assets: [PhotosPickerAsset]) {
        
        self.assets = assets
    }
    
    public func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosPickerAsset) -> Void)?) {
        
        let sortedAssets = self.assets.sort({ $0.creationDate?.compare($1.creationDate ?? NSDate()) == NSComparisonResult.OrderedDescending })
        for asset in sortedAssets {
            
            block?(asset: asset)
        }
    }
}

@available(iOS 8.0, *)
extension PHFetchResult: PhotosPickerAssets {
    
    public func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosPickerAsset) -> Void)?) {
        
        self.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            if let asset = asset as? PHAsset {
                
                block?(asset: asset)
            }
        }
    }
}

extension ALAssetsGroup: PhotosPickerAssets {
    
    public func requestDividedAssets(result: ((dividedAssets: DividedDayPhotosPickerAssets) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosPickerAsset) -> Void)?) {
        
        self.enumerateAssetsUsingBlock { (asset, index, stop) -> Void in
            
            block?(asset: asset)
        }
    }
}

public typealias DividedDayPhotosPickerAssets = [DayPhotosPickerAssets]

public struct DayPhotosPickerAssets: CustomStringConvertible {
    
    public var date: NSDate
    public var assets: [PhotosPickerAsset] = []
    
    public init(date: NSDate, assets: [PhotosPickerAsset] = []) {
        
        self.date = date
        self.assets = assets
    }
    
    public var description: String {
        
        let string: String = "\n Date:\(date) \nAssets: \(assets) \n"
        return string
    }
}

private func divideByDay(dateSortedAssets dateSortedAssets: PhotosPickerAssets) -> DividedDayPhotosPickerAssets {
    
    var dayAssets = DividedDayPhotosPickerAssets()
    
    var tmpDayAsset: DayPhotosPickerAssets!
    var processingDate: NSDate!
    
    dateSortedAssets.enumerateAssetsUsingBlock { (asset) -> Void in
        
        processingDate = dateWithOutTime(asset.creationDate)
        if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.date) == false {
            
            dayAssets.append(tmpDayAsset!)
            tmpDayAsset = nil
        }
        
        if tmpDayAsset == nil {
            
            tmpDayAsset = DayPhotosPickerAssets(date: processingDate)
        }
        
        tmpDayAsset.assets.append(asset)
        
    }
    
    return dayAssets
}

private func dateWithOutTime(date: NSDate!) -> NSDate {
    
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    let units: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
    let comp: NSDateComponents = calendar.components(units, fromDate: date)
    return calendar.dateFromComponents(comp)!
}
