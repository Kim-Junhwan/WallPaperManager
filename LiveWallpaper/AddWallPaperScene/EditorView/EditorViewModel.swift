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
    var displayMode: DisplayMode = .idle
    var showInspector: Bool = false
    /// 사용자가 조절한 배경 이미지 frame (캔버스 좌표). nil이면 레이아웃 기본값(가운데 정렬)을 쓴다.
    var wallpaperFrame: CGRect?
    var isWallpaperSelected: Bool = false
    /// 캔버스 레이아웃 기준 크기. 커지기만 하고 줄지 않아 인스펙터 토글 등에 영향받지 않는다.
    private(set) var canvasSize: CGSize?

    init(asset: WallpaperAsset) {
        self.asset = asset
        prepareEditor()
    }
    
    convenience init(state: EditorState, asset: WallpaperAsset) {
        self.init(asset: asset)
        self.state = state
    }

    /// 뷰포트 크기에 맞춰 캔버스를 키우기만 한다. (줄이지 않으므로 인스펙터 토글에 영향받지 않는다)
    /// 인스펙터가 열린 동안에는 뷰포트가 그만큼 좁으므로 그 폭을 더해 닫힌 상태와 같은 기준으로 맞춘다.
    func expandCanvasSize(toFit viewport: CGSize) {
        guard viewport.width > 0, viewport.height > 0 else { return }
        let width = viewport.width + (showInspector ? AppConstant.editorInspectorWidth : 0)
        let current = canvasSize ?? .zero
        let next = CGSize(width: max(current.width, width), height: max(current.height, viewport.height))
        if next != current { canvasSize = next }
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
            displayMode = .single(display: displayInfos.first!)
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
