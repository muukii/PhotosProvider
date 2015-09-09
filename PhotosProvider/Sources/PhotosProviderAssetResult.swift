//
//  PhotosProviderAssetResult.swift
//  PhotosProvider
//
//  Created by Muukii on 9/3/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import UIKit

public enum PhotosProviderAssetResultErrorType: ErrorType {
    case Unknown
}

public enum PhotosProviderAssetResult {
    case Success(UIImage)
    case Failure(ErrorType)
}