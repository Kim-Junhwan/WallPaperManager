//
//  EditorView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import SwiftUI

struct EditorView: View {
    let asset: WallpaperAsset
    @State var wallpaperName: String = "Untitled"
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Wallpaper Name", text: $wallpaperName)
                .frame(width: 300)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
//    var typeBadge: some View {
//        let text = switch asset.type {
//        case .image(_):
//            "Image"
//        case .video(_):
//            "Video"
//        }
//        
//        Text(text)
//            .
//    }
}

#Preview("Image Editor") {
    let previewImageURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Assets.xcassets/AppIcon.appiconset/512.png")

    EditorView(
        asset: WallpaperAsset(
            id: "editor-preview-image",
            url: previewImageURL,
            type: .image(.default),
            thumbnail: previewImageURL,
            createdAt: .now
        )
    )
    .frame(width: 960, height: 640)
}
