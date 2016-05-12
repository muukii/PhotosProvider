//
//  AssetsGroupByDay.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public class PhotosProviderAssetsGroupByDay {
    
    public class DayAssets {
        
        public var day: NSDate
        public var assets: [PhotosProviderAsset]
        
        public var numberOfAssets: Int {
            return self.assets.count            
        }
        
        public init(day: NSDate, assets: [PhotosProviderAsset] = []) {
            
            self.day = day
            self.assets = assets
        }
    }
    
    public var dayAssets = [DayAssets]()
    
    public var numberOfDays: Int {
        
        return dayAssets.count
    }
    
    public subscript (date date: NSDate) -> [PhotosProviderAsset] {

        return self.dayAssets.filter { $0.day == date }.first?.assets ?? []
    }
    
    public subscript (index: Int) -> DayAssets? {
        
        guard self.dayAssets.count > index else {
            
            return nil
        }
        
        return self.dayAssets[index]
    }
    
    public func allDayAssets() -> [PhotosProviderAsset] {
        
        return dayAssets.reduce([PhotosProviderAsset]()) { $0 + $1.assets }
    }
}