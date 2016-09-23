//
//  PhotosProviderAssetsGroup.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import Photos
import CoreLocation

public protocol PhotosProviderAssetsGroup {
    
    func requestAssetsGroupByDays(_ result: ((_ assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?)
    func enumerateAssets(_ block: ((_ asset: PhotosProviderAsset) -> Void)?)
    
    var count: Int { get }

    subscript (index: Int) -> PhotosProviderAsset? { get }
    var first: PhotosProviderAsset? { get }
    var last: PhotosProviderAsset? { get }
}

open class CustomAssetsGroup: PhotosProviderAssetsGroup {
    
    open private(set) var assets : [PhotosProviderAsset] = []
    
    public init(assets: [PhotosProviderAsset]) {
        
        self.assets = assets
    }
    
    open func requestAssetsGroupByDays(_ result: ((_ assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?) {
        
        DispatchQueue.global(qos: .default).async {
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            DispatchQueue.main.async {
                
                result?(dividedAssets)
            }
        }
    }
    
    open func enumerateAssets(_ block: ((_ asset: PhotosProviderAsset) -> Void)?) {
        
        let sortedAssets = assets.sorted(by: {
            $0.creationDate ?? Date() > $1.creationDate ?? Date()
        })
        for asset in sortedAssets {
            
            block?(asset)
        }
    }
    
    open var count: Int {
        
        return assets.count
    }
    
    open subscript (index: Int) -> PhotosProviderAsset? {
        
        return assets[index]
    }
    
    open var first: PhotosProviderAsset? {
        
        return assets.first
    }
    
    open var last: PhotosProviderAsset? {
        
        return assets.last
    }
}

public class AssetGroup: PhotosProviderAssetsGroup {
    
    public private(set) var assets : PHFetchResult<PHAsset>
    
    public init(fetchResult: PHFetchResult<PHAsset>) {
        
        self.assets = fetchResult
    }
    
    public func requestAssetsGroupByDays(_ result: ((_ assetsGroupByDay: PhotosProviderAssetsGroupByDay) -> Void)?) {
        
        DispatchQueue.global(qos: .default).async {
            
            let dividedAssets = divideByDay(dateSortedAssets: self)
            
            DispatchQueue.main.async {
                
                result?(dividedAssets)
            }
        }
    }
    
    public func enumerateAssets(_ block: ((_ asset: PhotosProviderAsset) -> Void)?) {
        
        assets.enumerateObjects({ (asset: PHAsset, index, stop) in
            block?(asset)
        })
    }
    
    public var count: Int {
        
        return assets.count
    }
    
    public subscript (index: Int) -> PhotosProviderAsset? {
        
        return assets[index]
    }
    
    public var first: PhotosProviderAsset? {
        
        return assets.firstObject
    }
    
    public var last: PhotosProviderAsset? {
        
        return assets.lastObject
    }
}

fileprivate func divideByDay(dateSortedAssets: PhotosProviderAssetsGroup) -> PhotosProviderAssetsGroupByDay {
    
    let dayAssets = PhotosProviderAssetsGroupByDay()
    
    var tmpDayAsset: PhotosProviderAssetsGroupByDay.DayAssets!
    var processingDate: Date!
    
    dateSortedAssets.enumerateAssets { (asset) -> Void in
        
        processingDate = dateWithoutTime(asset.creationDate as Date!)
        if tmpDayAsset != nil && processingDate != tmpDayAsset!.day {
            
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

fileprivate func dateWithoutTime(_ date: Date!) -> Date {
    
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    return calendar.date(from: dateComponents)!
}
