//
//  EditorView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import SwiftUI

struct EditorView: View {
    @Bindable var viewModel: EditorViewModel
    
    init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .loaded(let thumbnail):
            if let display = viewModel.displayInfo.first(where: { $0.isPrimary }) {
                editorCanvas(thumbnail: thumbnail, display: display)
            }
//            .inspector(isPresented: $viewModel.showInspector) {
//                WallpaperInspectorView()
//                    .inspectorColumnWidth(
//                        min: AppConstant.editorInspectorWidthMin,
//                        ideal: AppConstant.editorInspectorWidth,
//                        max: AppConstant.editorInspectorWidthMax)
//            }
//            .toolbar {
//                ToolbarItem {
//                    Button {
//                        viewModel.showInspector.toggle()
//                    } label: {
//                        Image(systemName: "sidebar.trailing")
//                    }
//                    
//                }
//            }
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .tint(.blue)
    }
    
    private func editorCanvas(
            thumbnail: NSImage,
            display: DisplayInfo
        ) -> some View {
            GeometryReader { proxy in
                let displaySize = CGSize(
                    width: display.resolutionWidth,
                    height: display.resolutionHeight
                )

                let layout = SingleDisplayLayout.calculate(
                    editorSize: proxy.size,
                    displaySize: displaySize,
                    wallpaperSize: thumbnail.size
                )

                ZStack {
                    Color(nsColor: .controlBackgroundColor)

                    Image(nsImage: thumbnail)
                        .resizable()
                        .frame(
                            width: layout.wallpaperSize.width,
                            height: layout.wallpaperSize.height
                        )

                    RoundedRectangle(
                        cornerRadius: 6,
                        style: .continuous
                    )
                    .stroke(.white.opacity(0.7), lineWidth: 1)
                    .frame(
                        width: layout.displaySize.width,
                        height: layout.displaySize.height
                    )
                    .allowsHitTesting(false)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
        }
}

#Preview("Image Editor") {
    let previewImageURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Assets.xcassets/AppIcon.appiconset/512.png")
    
    EditorView(
        viewModel: .init(state: .loaded(.kaguya), asset: WallpaperAsset(
            id: "editor-preview-image",
            url: previewImageURL,
            type: .image(.default),
            thumbnail: previewImageURL,
            createdAt: .now
        )
        )
    )
    .frame(width: CGFloat(AppConstant.windowWidth), height: CGFloat(AppConstant.windowHeight))
    .onAppear {
        
    }
}
