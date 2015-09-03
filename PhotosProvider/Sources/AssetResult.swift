//
//  AssetResult.swift
//  PhotosProvider
//
//  Created by Muukii on 9/3/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation

public enum AssetResultErrorType: ErrorType {
    case Unknown
}

public enum AssetResult {
    case Success(UIImage)
    case Failure(ErrorType)
}