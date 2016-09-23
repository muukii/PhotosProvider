//
//  AssetsGroupByDay.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

open class PhotosProviderAssetsGroupByDay {
    
    open class DayAssets {
        
        open var day: Date
        open var assets: [PhotosProviderAsset]
        
        open var numberOfAssets: Int {
            return assets.count
        }
        
        public init(day: Date, assets: [PhotosProviderAsset] = []) {
            
            self.day = day
            self.assets = assets
        }
    }
    
    open var dayAssets = [DayAssets]()
    
    open var numberOfDays: Int {
        
        return dayAssets.count
    }
    
    open subscript (date date: Date) -> [PhotosProviderAsset] {

        return dayAssets.filter { $0.day == date }.first?.assets ?? []
    }
    
    open subscript (index: Int) -> DayAssets? {
        
        guard dayAssets.count > index else {
            
            return nil
        }
        
        return dayAssets[index]
    }
    
    open func allDayAssets() -> [PhotosProviderAsset] {
        
        return dayAssets.reduce([PhotosProviderAsset]()) { $0 + $1.assets }
    }
}
