//
//  SizeEditableView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/5/26.
//

import SwiftUI

struct SizeEditableView<Content: View>: View {
    
    let content: () -> Content
    let selected: Bool
    
    init(content: @escaping () -> Content,
         selected: Bool
    ) {
        self.content = content
        self.selected = selected
    }
    
    var body: some View {
        content()
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.purple, lineWidth: 10)
                        .pointerStyle(.columnResize)
                }
            }
    }
}

#Preview {
    SizeEditableView(content: { Image(.kaguya) }, selected: true)
}
