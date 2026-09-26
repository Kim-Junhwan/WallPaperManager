//
//  LiveWallpaperApp.swift
//  LiveWallpaper
//


import SwiftUI

@main
struct LiveWallpaperApp: App {
    
    let userSetting = UserSetting.shared
    
    
    var body: some Scene {
        MenuBarExtra("Menu", systemImage: "shippingbox.fill") {
            MenuBarView()
        }
    }
    
    init() {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
#endif
        runOnLaunch()
        DispatchQueue.main.async {
            if !UserSetting.shared.doNotShowWindow {
                WindowManager.showWindow()
            }
        }
    }
    
    func runOnLaunch(){
        print("applaunch \(userSetting.video)")
        guard let video = userSetting.video else { return }
        WallpaperManager.shared.setWallpaper(asset: video)
        
    }
    
    
}


struct MenuBarView: View {
    
    @ObservedObject var wallpaperManager = WallpaperManager.shared
    @ObservedObject var userSetting = UserSetting.shared
    
    var body: some View {
        VStack {
            Button("Open Main UI") {
                WindowManager.showWindow()
            }
            
            Divider()
            
            Toggle("Ambient Sounds", isOn: $userSetting.mixerEnabled)
                .toggleStyle(.checkbox)
            
            Button {
                wallpaperManager.toggleMute()
            } label: {
                HStack {
                    if wallpaperManager.player?.isMuted == true {
                        Text("Unmute Wallpaper")
                    } else {
                        Text("Mute Wallpaper")
                    }
                    
                }
            }
            .disabled(wallpaperManager.player == nil)
            
            Button {
                wallpaperManager.togglePlaying()
            } label: {
                HStack {
                    if wallpaperManager.player?.rate == 0 {
                        Text("Resume Wallpaper")
                    } else {
                        Text("Pause Wallpaper")
                    }
                    
                }
            }
            .disabled(wallpaperManager.player == nil)
            
            Divider()
            
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        
        
    }
}
