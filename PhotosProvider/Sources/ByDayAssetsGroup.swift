//
//  ByDayAssetsGroup.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public struct ByDayAssetsGroup {
    
    public var day: NSDate
    public var assets: [Asset]
    
    public init(day: NSDate, assets: [Asset] = []) {
        
        self.day = day
        self.assets = assets
    }
}