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
    
    static let windowWidth: Int = 1200
    
    static let windowHeight: Int = 760
    
    static let editorInspectorWidth: CGFloat = 300
    static let editorInspectorWidthMin: CGFloat = 260
    static let editorInspectorWidthMax: CGFloat = 360
    
    static let editorWidthPadding: CGFloat = 18
    static let editorHeightPadding: CGFloat = 36
}
