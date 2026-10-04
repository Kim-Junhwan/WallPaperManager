//
//  DropViewModel.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/22/26.
//

import Foundation
import UniformTypeIdentifiers
import AVFoundation
import AppKit

enum UploadAssetState {
    case idle
    case empty(UploadAssetViewModel)
    case editor(EditorViewModel)
}

enum AssetUploadError: Error {
    case notFoundFile
    case failedGenerateThumbnail
}

@MainActor
@Observable
class AddWallpaperFlowSession {

    var state: UploadAssetState = .idle


    init() {
        state = .empty(UploadAssetViewModel(successUploadAsset: { asset in
            self.state = .editor(.init(asset: asset))
        }))
    }
}
