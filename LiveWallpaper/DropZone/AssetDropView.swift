import SwiftUI
import AVKit

struct AssetDropView: View {
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State var video:WallpaperAsset?
    @State private var showToast = false
    let uploadViewModel: UploadAssetwModel

    var body: some View {
        contentView
        .overlay {
            if uploadViewModel.isUploading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .overlay {
            if showToast {
                Toast(systemImage: "checkmark.circle.fill", message: "Wallpaper Set", isVisible: $showToast)
            }
        }

    }

    @ViewBuilder
    var contentView: some View {
        switch uploadViewModel.state {
        case .empty:
            dropZoneView
        case .loaded(let wallpaperAsset):
            VStack {
                switch wallpaperAsset.type {
                case .image(let imageData):
                    if let image = NSImage(contentsOf: wallpaperAsset.thumbnail) {
                        Image(nsImage: image)
                    } else {
                        Image(systemName: "photo")
                    }
                case .video(_):
                    videoPlayerView
                }
                setWallPaperButton
            }
        }
    }

    var dropZoneView: some View {
        DropZoneView(onDrop: { providers in
            return uploadViewModel.uploadAsset(providers)
        }, onSelect: {
            selectAssetFile()
        })
    }

    var setWallPaperButton: some View {
        Button("Set as Wallpaper", action: {
            WallpaperManager.shared.setWallpaperVideo(video: video!)
            UserSetting.shared.setVideo(video!)
            video = nil
            player = nil
            toast()
        })
        .opacity(video != nil ? 1.0 : 0.0)
        .buttonStyle(.borderedProminent)
        .padding()
    }

    var videoPlayerView: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(height: 300)
                .cornerRadius(10)
                .padding()


        }
    }

    private func toast() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }

    private func selectAssetFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = AppConstant.supportAssetType
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.urls.first {
            uploadViewModel.uploadAsset(url)
        }
    }
}

struct DropZoneView: View {
    var onDrop: ([NSItemProvider]) -> Bool
    var onSelect: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [5]))
            .background(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                VStack {
                    Text("Drag & Drop your video here\nor Click to select")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .font(.title3)
                    Text(".mp4, .mov supported")
                        .padding(4)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
            .onDrop(of: AppConstant.supportAssetType, isTargeted: nil) { providers in
                return onDrop(providers)
            }
    }
}

struct AssetDropView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDropView(video: nil, uploadViewModel: .init())
    }
}
