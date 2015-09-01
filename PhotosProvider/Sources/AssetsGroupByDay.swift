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
        
        public init(day: NSDate, assets: [Asset] = []) {
            
            self.day = day
            self.assets = assets
        }
    }
    
    public var dayAssets = [DayAssets]()
    
    public subscript (date: NSDate) -> [Asset] {

        return self.dayAssets.filter { $0.day == date }.first?.assets ?? []

    }
    
    public func allDayAssets() -> [Asset] {
        
        return dayAssets.reduce([Asset]()) { $0 + $1.assets }
    }
}