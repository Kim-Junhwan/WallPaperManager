//
//  AddWallPaperFlowView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/26/26.
//

import SwiftUI

struct AddWallPaperFlowView: View {

    let addSession: AddWallpaperFlowSession
    
    var body: some View {
        switch addSession.state {
        case .empty(let uploadViewModel):
            AssetDropView(uploadViewModel: uploadViewModel)
        case .editor(let editorViewModel):
            EditorView(viewModel: editorViewModel)
        case .idle:
            EmptyView()
        }
    }
}
