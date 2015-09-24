//
//  PhotosProviderAssetsGroup.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary
import CoreLocation

#if !PHOTOSPROVIDER_EXCULE_IMPORT_MODULES
    import GCDKit
#endif

public protocol PhotosProviderAssetsGroup {
    
    func requestAssetsGroupByDays(result: ((assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?)
    func enumerateAssetsUsingBlock(block: ((asset: PhotosProviderAsset) -> Void)?)
    
    var count: Int { get }
    
    subscript (index: Int) -> PhotosProviderAsset? { get }
    var first: PhotosProviderAsset? { get }
    var last: PhotosProviderAsset? { get }
}

public class CustomAssetsGroup: PhotosProviderAssetsGroup {
    
    public private(set) var assets : [PhotosProviderAsset] = []
    
    public init(assets: [PhotosProviderAsset]) {
        
        self.assets = assets
    }
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?) {
        
        GCDBlock.async(.Default) {
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            GCDBlock.async(.Main) {
                result?(assetsGroupByDay: dividedAssets)
            }
        }
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosProviderAsset) -> Void)?) {
        
        let sortedAssets = self.assets.sort({ $0.creationDate?.compare($1.creationDate ?? NSDate()) == NSComparisonResult.OrderedDescending })
        for asset in sortedAssets {
            
            block?(asset: asset)
        }
    }
    
    public var count: Int {
        
        return self.assets.count
    }
    
    public subscript (index: Int) -> PhotosProviderAsset? {
        
        return self.assets[index]
    }
    
    public var first: PhotosProviderAsset? {
        
        return self.assets.first
    }
    
    public var last: PhotosProviderAsset? {
        
        return self.assets.last
    }
}

@available(iOS 8.0, *)
extension PHFetchResult: PhotosProviderAssetsGroup {
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?) {
        
        assert(self.count == 0 || self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        GCDBlock.async(.Default) {
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            GCDBlock.async(.Main) {
                result?(assetsGroupByDay: dividedAssets)
            }
        }
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosProviderAsset) -> Void)?) {
        
        assert(self.count == 0 || self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        self.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            if let asset = asset as? PHAsset {
                
                block?(asset: asset)
            }
        }
    }
        
    public subscript (index: Int) -> PhotosProviderAsset? {
        
        assert(self.count == 0 || self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        return self.objectAtIndex(index) as? PHAsset
    }
    
    
    public var first: PhotosProviderAsset? {
        
        return self.firstObject as? PhotosProviderAsset
    }
    
    public var last: PhotosProviderAsset? {
        
        return self.lastObject as? PhotosProviderAsset
    }
}

extension ALAssetsGroup: PhotosProviderAssetsGroup {
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?) {
        
        GCDBlock.async(.Default) {
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            GCDBlock.async(.Main) {
                result?(assetsGroupByDay: dividedAssets)
            }
        }
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: PhotosProviderAsset) -> Void)?) {

        self.enumerateAssetsUsingBlock { (asset, index, stop) -> Void in
            
            block?(asset: asset)
        }
    }
    
    public var count: Int {
        
        return self.count
    }
    
    public subscript (index: Int) -> PhotosProviderAsset? {
        
        return self.assets?[index]
    }
    
    var assets: [ALAsset]? {
        
        get {
            
            if let value = objc_getAssociatedObject(self, &StoredProperties.assets)  as? [ALAsset] {
                return value
            }
            
            var assets: [ALAsset] = []
            
            self.enumerateAssetsUsingBlock { (asset, index, stop) -> Void in
                
                assets.append(asset)
            }
            self.assets = assets
            return assets
        }
        set {
            
            objc_setAssociatedObject(
                self,
                &StoredProperties.assets,
                newValue,
                .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private struct StoredProperties {
        
        static var assets: Void?
    }
    
    public var first: PhotosProviderAsset? {
        
        return self.assets?.first
    }
    
    public var last: PhotosProviderAsset? {
        
        return self.assets?.last
    }
}

private func divideByDay(dateSortedAssets dateSortedAssets: PhotosProviderAssetsGroup) -> PhotosProviderAssetsGroupByDay {
    
    let dayAssets = PhotosProviderAssetsGroupByDay()
    
    var tmpDayAsset: PhotosProviderAssetsGroupByDay.DayAssets!
    var processingDate: NSDate!
    
    dateSortedAssets.enumerateAssetsUsingBlock { (asset) -> Void in
        
        processingDate = dateWithOutTime(asset.creationDate)
        if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.day) == false {
            
            tmpDayAsset = nil
        }
        
        if tmpDayAsset == nil {
            
            tmpDayAsset = PhotosProviderAssetsGroupByDay.DayAssets(day: processingDate)
            dayAssets.dayAssets.append(tmpDayAsset!)
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
