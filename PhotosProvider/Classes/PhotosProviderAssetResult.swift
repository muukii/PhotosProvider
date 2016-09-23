//
//  PhotosProviderAssetResult.swift
//  PhotosProvider
//
//  Created by Muukii on 9/3/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import UIKit

public enum PhotosProviderAssetResultErrorType: Error {
    case unknown
}

public enum PhotosProviderAssetResult {
    case success(UIImage)
    case failure(Error)
}
