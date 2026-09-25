import SwiftUI
import AVKit

struct AssetDropView: View {
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State var video:WallpaperAsset?
    @State private var showToast = false
    let dropViewModel: UploadAssetwModel
    
    var body: some View {
        ZStack {
            
            if player == nil {
                DropZoneView(onDrop: { providers in
                    return dropViewModel.uploadAsset(providers)
                }, onSelect: {
                    selectAssetFile()
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
    
    private func selectAssetFile() {
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
        AssetDropView(video: nil, dropViewModel: .init())
    }
}
