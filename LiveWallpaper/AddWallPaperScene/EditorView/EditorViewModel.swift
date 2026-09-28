//
//  EditorViewModel.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import Foundation

@Observable
class EditorViewModel {
    let asset: WallpaperAsset
    
    init(asset: WallpaperAsset) {
        self.asset = asset
    }
}

