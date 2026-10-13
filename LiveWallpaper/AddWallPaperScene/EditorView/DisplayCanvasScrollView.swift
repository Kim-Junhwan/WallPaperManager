//
//  DisplayCanvasScrollView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/8/26.
//

import SwiftUI

struct DisplayCanvasScrollView<Content: View>: NSViewRepresentable {
    let contentSize: CGSize
    let content: () -> Content
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.documentView = context.coordinator.hostingView
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        
        scrollView.allowsMagnification = true
        scrollView.minMagnification = 0.25
        scrollView.maxMagnification = 4.0
        
        context.coordinator.hostingView.frame = NSRect(origin: .zero, size: contentSize)
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let hostingView = context.coordinator.hostingView
        
        hostingView.rootView = content()
        
        if hostingView.frame.size != contentSize {
            hostingView.setFrameSize(contentSize)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content())
    }
    
    @MainActor
    final class Coordinator {
        let hostingView: NSHostingView<Content>
        
        init(content: Content) {
            self.hostingView = NSHostingView(rootView: content)
        }
    }
}
