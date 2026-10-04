//
//  EditorView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import SwiftUI

struct EditorView: View {
    @State var viewModel: EditorViewModel
    
    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("hello ")
    }
}

#Preview("Image Editor") {
    let previewImageURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Assets.xcassets/AppIcon.appiconset/512.png")

    EditorView(
        viewModel: .init(asset: WallpaperAsset(
            id: "editor-preview-image",
            url: previewImageURL,
            type: .image(.default),
            thumbnail: previewImageURL,
            createdAt: .now
        ))
    )
    .frame(width: 960, height: 640)
}
