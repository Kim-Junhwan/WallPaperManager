//
//  EditorViewModel.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import Foundation
import AppKit

enum AssetError: Error {
    case notFoundFile
}

enum EditorState {
    case loading
    case loaded(NSImage)
}

struct SingleDisplayLayout {
    let wallpaperSize: CGSize
    let displaySize: CGSize
    
    static func calculate(
        editorSize: CGSize,
        displaySize: CGSize,
        wallpaperSize: CGSize
    ) -> SingleDisplayLayout {
        let margin = min(max(min(editorSize.width, editorSize.height) * 0.08, 32),64)
        
        let safeEditorSize = CGSize(
            width: max(0, editorSize.width - margin*2),
            height: max(0, editorSize.height - margin*2)
        )
        
        let fillScale = max(
            displaySize.width / wallpaperSize.width,
            displaySize.height / wallpaperSize.height
        )
        
        let wallpaperInDisplay = CGSize(width: wallpaperSize.width * fillScale, height: wallpaperSize.height * fillScale)
        
        let presentationScale = min(
            safeEditorSize.width / wallpaperInDisplay.width,
            safeEditorSize.height / wallpaperInDisplay.height
        )
        
        return .init(
            wallpaperSize: CGSize(width: wallpaperInDisplay.width * presentationScale, height: wallpaperInDisplay.height * presentationScale),
            displaySize: CGSize(width: displaySize.width * presentationScale, height: displaySize.height * presentationScale)
        )
    }
}

@Observable
@MainActor
final class EditorViewModel {
    let asset: WallpaperAsset
    
    var state: EditorState = .loading
    var displayInfo: [DisplayInfo] = []
    var displayMode: DisplayMode = .single
    var showInspector: Bool = true

    init(asset: WallpaperAsset) {
        self.asset = asset
        prepareEditor()
    }
    
    convenience init(state: EditorState, asset: WallpaperAsset) {
        self.init(asset: asset)
        self.state = state
    }

    func prepareEditor() {
        do {
            let thumbnail = try getAssetThumbnail()
            let displayInfos = try getDisplayInfo()
            
            /// 우선은 Single 부터
//            if displayInfos.count < 2 {
//                displayMode = .single
//            } else {
//                displayMode = .perDisplay
//            }
            displayMode = .single
            state = .loaded(thumbnail)
        } catch {

        }
    }

    func getDisplayInfo() throws -> [DisplayInfo]  {
        let displayInfos = try DisplayManager.getDisplayInfos()
        displayInfo = displayInfos
        return displayInfos
    }
    
    func getAssetThumbnail() throws -> NSImage {
        let thumbnailPath = asset.thumbnail.path(percentEncoded: false)
        if let thumbnail = NSImage(contentsOfFile: thumbnailPath) {
            return thumbnail
        } else {
            throw AssetError.notFoundFile
        }
    }
}
