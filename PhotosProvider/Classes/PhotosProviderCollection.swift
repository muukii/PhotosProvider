//
//  Collection.swift
//  PhotosProvider
//
//  Created by Muukii on 8/7/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public func == (lhs: PhotosProviderCollection, rhs: PhotosProviderCollection) -> Bool {
    
    return lhs === rhs
}

public class PhotosProviderCollection: Hashable {
    
    public private(set) var title: String
    public private(set) var group: PhotosProviderAssetsGroup
    
    public init(title: String, group: PhotosProviderAssetsGroup, buildGroupByDay: Bool = false) {
        
        self.title = title
        self.group = group

        if buildGroupByDay {
            self.group.requestAssetsGroupByDays { groupByDay in
                self.groupByDay = groupByDay
            }
        }
    }
    
    func requestGroupByDay(completion: (groupByDay: PhotosProviderAssetsGroupByDay) -> Void) {
        
        if let groupByDay = self.groupByDay {
            completion(groupByDay: groupByDay)
            return
        }
        
        self.group.requestAssetsGroupByDays { _groupByDay in
            
            self.groupByDay = _groupByDay
            completion(groupByDay: _groupByDay)
        }
    }
    
    private var groupByDay: PhotosProviderAssetsGroupByDay?
    
    public var hashValue: Int {
        
        return ObjectIdentifier(self).hashValue
    }
}