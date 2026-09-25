import SwiftUI
import AVKit

enum NavItem: String, CaseIterable {
    case addAsset = "Add Wallpaper"
    case recent = "Recents"
    case ambientMixer = "Ambient Sounds"
    case settings = "Settings"
}

struct ContentView: View {
    @State private var selectedItem: NavItem = .addAsset
    @State private var sideBarVisible: NavigationSplitViewVisibility = .all
    @State private var dropViewModel: UploadAssetwModel = .init()
    
    let recent = Recent()
    let ambientSounds = AmbientSounds()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisible) {
            List(selection: $selectedItem) {
                ForEach(NavItem.allCases, id: \.self) { item in
                    Text(item.rawValue)
                        .tag(item)
                }
            }
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            selectedView
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    toggleSidebar()
                } label: {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    @ViewBuilder
    var selectedView: some View {
        switch selectedItem {
        case .addAsset:
            AssetDropView(uploadViewModel: dropViewModel)
        case .recent:
            recent
        case .ambientMixer:
            ambientSounds
        case .settings:
            SettingView()
        }
    }
    
    private func toggleSidebar() {
        withAnimation {
            sideBarVisible = sideBarVisible == .detailOnly ? .all : .detailOnly
        }
    }
}

#Preview {
    ContentView()
}
