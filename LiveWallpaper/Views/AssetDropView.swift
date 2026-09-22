import SwiftUI
import AVKit

enum DropAssetState {
    case empty
    case loading
    case loaded(WallpaperAsset)
    case failed(String)
}

struct AssetDropView: View {
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State var video:WallpaperAsset?
    @State private var showToast = false
    @State private var state: DropAssetState = .empty
    
    var body: some View {
        ZStack {
            
            if player == nil {
                DropZoneView(onDrop: { url in
                    loadVideo(from: url)
                }, onSelect: {
                    selectVideoFile()
                })
            } else {
                VStack {
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()
                    
                    Button("Set as Wallpaper", action: {
                        player?.pause()
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
            }
            
            if showToast {
                Toast(systemImage: "checkmark.circle.fill", message: "Wallpaper Set", isVisible: $showToast)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        
    }
    
    private func toast() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    private func loadVideo(from url: URL) {
        videoURL = url
        player = AVPlayer(url: url)
        player?.play()
        
        let id = UUID().uuidString
        
        Task {
            do {
                let copiedFileURL = try await copyFile(fileURL: url, targetFilename: id)
                guard let thumbnailPath = await generateThumbnailAndSave(from: copiedFileURL.path(percentEncoded: false), fileName: "\(id).png") else {return}
                let attrs = await analyzeVideoCharacteristics(url: url) ?? .default
                video = WallpaperAsset(id: id, url: copiedFileURL.path(percentEncoded: false), type: .video(attrs), thumbnail: thumbnailPath, createdAt: Date())
            } catch {
                print("Error copying file: \(error)")
            }
        }
        
    }
    
    private func selectVideoFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = AppConstant.supportAssetType
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.urls.first {
            loadVideo(from: url)
        }
    }
}

struct DropZoneView: View {
    var onDrop: (URL) -> Void
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
                if let imageProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
                    dropImage(imageProvider)
                } else if let videoProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.movie.identifier) }) {
                    dropVideo(videoProvider)
                } else {
                    return false
                }
                return true  // Accept the drop
            }
    }

    private func dropImage(_ item: NSItemProvider) {
        let _ = item.loadFileRepresentation(for: .image) { url, inplace, error in
            guard error == nil else { print("Image Drop Error: \(String(describing: error))"); return }

            guard let url else { return }

            Task { @MainActor in
                onDrop(url)
            }
        }
    }

    private func dropVideo(_ item: NSItemProvider) {
        let _ = item.loadFileRepresentation(for: .movie) { url, inplace, error in
            guard error == nil else { print("Video Drop Error: \(String(describing: error))"); return }

            guard let url else { return }

            Task { @MainActor in
                onDrop(url)
            }
        }
    }
}

struct AssetDropView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDropView(video: nil)
    }
}
