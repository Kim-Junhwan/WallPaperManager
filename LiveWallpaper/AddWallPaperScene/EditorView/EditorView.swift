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
           displayCanvasView(thumbnail: thumbnail)
            .inspector(isPresented: $viewModel.showInspector) {
                WallpaperInspectorView()
                    .inspectorColumnWidth(
                        min: AppConstant.editorInspectorWidthMin,
                        ideal: AppConstant.editorInspectorWidth,
                        max: AppConstant.editorInspectorWidthMax)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.showInspector.toggle()
                    } label: {
                        Image(systemName: "sidebar.trailing")
                    }
                    
                }
            }
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .tint(.blue)
    }
    
    @ViewBuilder
    private func displayCanvasView(thumbnail: NSImage) -> some View {
        GeometryReader { proxy in
            // 인스펙터 토글 등으로 뷰포트가 바뀌어도 캔버스 크기는 줄어들지 않고 고정된다.
            let canvasSize = viewModel.canvasSize ?? proxy.size
            DisplayCanvasScrollView(contentSize: canvasSize) {
                ZStack {
                    Color(nsColor: .controlBackgroundColor)
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.isWallpaperSelected = false }
                    switch viewModel.displayMode {
                    case .single(let displayInfo):
                        singleDisplayCanvas(canvasSize: canvasSize, thumbnail: thumbnail, display: displayInfo)
                    case .perDisplay:
                        EmptyView()
                    case .spanAll:
                        EmptyView()
                    case .idle:
                        EmptyView()
                    }
                }
                .canvasCoordinateSpace()
            }
            .onAppear { viewModel.expandCanvasSize(toFit: proxy.size) }
            .onChange(of: proxy.size) { _, newSize in viewModel.expandCanvasSize(toFit: newSize) }
        }
    }
    
    @ViewBuilder
    private func singleDisplayCanvas(canvasSize: CGSize, thumbnail: NSImage, display: DisplayInfo) -> some View {
        let displaySize = CGSize(
            width: display.resolutionWidth,
            height: display.resolutionHeight
        )
        
        let layout = SingleDisplayLayout.calculate(
            editorSize: canvasSize,
            displaySize: displaySize,
            wallpaperSize: thumbnail.size
        )
        
        let defaultFrame = CGRect(
            x: (canvasSize.width - layout.wallpaperSize.width) / 2,
            y: (canvasSize.height - layout.wallpaperSize.height) / 2,
            width: layout.wallpaperSize.width,
            height: layout.wallpaperSize.height
        )
        let wallpaperFrame = Binding(
            get: { viewModel.wallpaperFrame ?? defaultFrame },
            set: { viewModel.wallpaperFrame = $0 }
        )
        
        ZStack {
            Image(nsImage: thumbnail)
                .resizable()
                .frameMovable(
                    frame: wallpaperFrame,
                    isSelected: $viewModel.isWallpaperSelected
                )
                .sizeEditable(
                    frame: wallpaperFrame,
                    isSelected: $viewModel.isWallpaperSelected
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
