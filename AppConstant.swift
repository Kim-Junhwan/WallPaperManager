//
//  AppConstant.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/1/26.
//

import Foundation
import UniformTypeIdentifiers

public enum AppConstant {
    static let supportAssetType: [UTType] = [UTType.mpeg4Movie, UTType.quickTimeMovie, UTType.image]

    static let supportMovieType = [UTType.mpeg4Movie, UTType.quickTimeMovie]

    static let supportImageType = [UTType.image]
}
