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
    
    func requestDividedAssets(result: ((dividedAssets: [ByDayAssetsGroup]) -> Void)?)
    func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?)
}

public class PhotosPickerAssetsGroup: AssetsGroup {
    
    public private(set) var assets : [Asset] = []
    
    public init(assets: [Asset]) {
        
        self.assets = assets
    }
    
    public func requestDividedAssets(result: ((dividedAssets: [ByDayAssetsGroup]) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {
        
        let sortedAssets = self.assets.sort({ $0.creationDate?.compare($1.creationDate ?? NSDate()) == NSComparisonResult.OrderedDescending })
        for asset in sortedAssets {
            
            block?(asset: asset)
        }
    }
}

@available(iOS 8.0, *)
extension PHFetchResult: AssetsGroup {
    
    public func requestDividedAssets(result: ((dividedAssets: [ByDayAssetsGroup]) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {
        
        self.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            if let asset = asset as? PHAsset {
                
                block?(asset: asset)
            }
        }
    }
}

extension ALAssetsGroup: AssetsGroup {
    
    public func requestDividedAssets(result: ((dividedAssets: [ByDayAssetsGroup]) -> Void)?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                result?(dividedAssets: dividedAssets)
            })
        })
    }
    
    public func enumerateAssetsUsingBlock(block: ((asset: Asset) -> Void)?) {
        
        self.enumerateAssetsUsingBlock { (asset, index, stop) -> Void in
            
            block?(asset: asset)
        }
    }
}

private func divideByDay(dateSortedAssets dateSortedAssets: AssetsGroup) -> [ByDayAssetsGroup] {
    
    var dayAssets = [ByDayAssetsGroup]()
    
    var tmpDayAsset: ByDayAssetsGroup!
    var processingDate: NSDate!
    
    dateSortedAssets.enumerateAssetsUsingBlock { (asset) -> Void in
        
        processingDate = dateWithOutTime(asset.creationDate)
        if tmpDayAsset != nil && processingDate.isEqualToDate(tmpDayAsset!.day) == false {
            
            dayAssets.append(tmpDayAsset!)
            tmpDayAsset = nil
        }
        
        if tmpDayAsset == nil {
            
            tmpDayAsset = ByDayAssetsGroup(day: processingDate)
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