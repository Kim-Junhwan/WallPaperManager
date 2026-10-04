//
//  EditorViewModel.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import Foundation

@Observable
@MainActor
final class EditorViewModel {
    let asset: WallpaperAsset
    var displayInfo: [DisplayInfo] = []
    var displayMode: DisplayMode = .single

    init(asset: WallpaperAsset) {
        self.asset = asset
        prepareEditor()
    }

    func prepareEditor() {
        do {
            let displayInfos = try getDisplayInfo()
            if displayInfos.count > 2 {
                displayMode = .single
            } else {
                displayMode = .perDisplay
            }
        } catch {

        }
    }

    func getDisplayInfo() throws -> [DisplayInfo]  {
        let displayInfos = try DisplayManager.getDisplayInfos()
        displayInfo = displayInfos
        return displayInfos
    }
}
