//
//  Collection.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public struct Collection {
    
    public private(set) var title: String
    public private(set) var group: AssetsGroup
    public private(set) var byDayGroups: AssetsGroupByDay?
    
    public init(title: String, group: AssetsGroup) {
        
        self.title = title
        self.group = group
//        
//        self.group.requestAssetsGroupByDays { byDayGroups in
//            self.byDayGroups = byDayGroups
//        }
    }
}