//
//  AssetsGroupByDay.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public struct AssetsGroupByDay {
    
    public struct DayAssets {
        
        public var day: NSDate
        public var assets: [Asset]
        
        var numberOfAssets: Int {
            return self.assets.count            
        }
        
        public init(day: NSDate, assets: [Asset] = []) {
            
            self.day = day
            self.assets = assets
        }
    }
    
    public var dayAssets = [DayAssets]()
    
    public var numberOfDays: Int {
        
        return dayAssets.count
    }
    
    public subscript (date date: NSDate) -> [Asset] {

        return self.dayAssets.filter { $0.day == date }.first?.assets ?? []
    }
    
    public subscript (index: Int) -> DayAssets? {
        
        guard self.dayAssets.count > index else {
            
            return nil
        }
        
        return self.dayAssets[index]
    }
    
    public func allDayAssets() -> [Asset] {
        
        return dayAssets.reduce([Asset]()) { $0 + $1.assets }
    }
}