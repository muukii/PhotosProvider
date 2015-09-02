//
//  AssetsGroup.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary
import CoreLocation

public protocol AssetsGroup {
    
    func requestAssetsGroupByDays(result: ((assetsGroupByDay: AssetsGroupByDay) -> Void)?)
    func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?)
    
    var count: Int { get }
    
    subscript (index: Int) -> Asset? { get }
}

public class CustomAssetsGroup: AssetsGroup {
    
    public private(set) var assets : [Asset] = []
    
    public init(assets: [Asset]) {
        
        self.assets = assets
    }
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: AssetsGroupByDay) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(assetsGroupByDay: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {
        
        let sortedAssets = self.assets.sort({ $0.creationDate?.compare($1.creationDate ?? NSDate()) == NSComparisonResult.OrderedDescending })
        for asset in sortedAssets {
            
            block?(asset: asset)
        }
    }
    
    public var count: Int {
        
        return self.assets.count
    }
    
    public subscript (index: Int) -> Asset? {
        
        return self.assets[index]
    }
}

@available(iOS 8.0, *)
extension PHFetchResult: AssetsGroup {
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: AssetsGroupByDay) -> Void)?) {
        
        assert(self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(assetsGroupByDay: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {
        
        assert(self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        self.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            if let asset = asset as? PHAsset {
                
                block?(asset: asset)
            }
        }
    }
        
    public subscript (index: Int) -> Asset? {
        
        assert(self.firstObject is PHAsset, "AssetsGroup must be PHFetchResult of PHAsset.")
        
        return self.objectAtIndex(index) as? PHAsset
    }
}

extension ALAssetsGroup: AssetsGroup {
    
    public func requestAssetsGroupByDays(result: ((assetsGroupByDay: AssetsGroupByDay) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(assetsGroupByDay: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {

        self.enumerateAssetsUsingBlock { (asset, index, stop) -> Void in
            
            block?(asset: asset)
        }
    }
    
    public var count: Int {
        
        return self.count
    }
    
    public subscript (index: Int) -> Asset? {
        
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
}

private func divideByDay(dateSortedAssets dateSortedAssets: AssetsGroup) -> AssetsGroupByDay {
    
    var dayAssets = AssetsGroupByDay()
    
    var tmpDayAsset: AssetsGroupByDay.DayAssets!
    var processingDate: NSDate!
    
    dateSortedAssets.enumerateAssetsUsingBlock { (asset) -> Void in
        
        processingDate = dateWithOutTime(asset.creationDate)
        if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.day) == false {
            
            dayAssets.dayAssets.append(tmpDayAsset!)
            tmpDayAsset = nil
        }
        
        if tmpDayAsset == nil {
            
            tmpDayAsset = AssetsGroupByDay.DayAssets(day: processingDate)
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