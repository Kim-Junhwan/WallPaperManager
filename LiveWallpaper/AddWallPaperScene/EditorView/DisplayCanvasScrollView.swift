//
//  DisplayCanvasScrollView.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/8/26.
//

import SwiftUI

/// 스크롤 + 핀치 확대가 되는 캔버스 컨테이너.
///
/// `NSScrollView.allowsMagnification`은 documentView를 AppKit 레벨에서 확대하는데,
/// 이 상태에서는 `NSHostingView` 안 SwiftUI의 hit-test/제스처 위치가 어긋난다.
/// 그래서 확대는 SwiftUI `scaleEffect`로 처리하고, 핀치 입력만 `NSScrollView`에서 받는다.
/// `content` 안에 둔 좌표계(`canvasCoordinateSpace`)는 확대 배율과 무관한 캔버스 단위를 돌려준다.
struct DisplayCanvasScrollView<Content: View>: NSViewRepresentable {
    let contentSize: CGSize
    let content: () -> Content

    func makeNSView(context: Context) -> CanvasNSScrollView {
        let scrollView = CanvasNSScrollView()
        scrollView.documentView = context.coordinator.hostingView
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        context.coordinator.scrollView = scrollView
        scrollView.onMagnify = { [weak coordinator = context.coordinator] delta, windowPoint in
            coordinator?.magnify(by: delta, atWindowPoint: windowPoint)
        }

        context.coordinator.update(contentSize: contentSize, content: content)
        return scrollView
    }

    func updateNSView(_ nsView: CanvasNSScrollView, context: Context) {
        context.coordinator.update(contentSize: contentSize, content: content)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(contentSize: contentSize, content: content)
    }

    // MARK: - Scaled content

    struct ScaledCanvas: View {
        let size: CGSize
        let scale: CGFloat
        let content: Content

        var body: some View {
            content
                .frame(width: size.width, height: size.height)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: size.width * scale, height: size.height * scale, alignment: .topLeading)
        }
    }

    // MARK: - Coordinator

    @MainActor
    final class Coordinator {
        static var magnificationRange: ClosedRange<CGFloat> { 0.25...4.0 }

        let hostingView: NSHostingView<ScaledCanvas>
        weak var scrollView: NSScrollView?

        private var contentSize: CGSize
        private var content: () -> Content
        private(set) var scale: CGFloat = 1

        init(contentSize: CGSize, content: @escaping () -> Content) {
            self.contentSize = contentSize
            self.content = content
            self.hostingView = NSHostingView(
                rootView: ScaledCanvas(size: contentSize, scale: 1, content: content())
            )
        }

        func update(contentSize: CGSize, content: @escaping () -> Content) {
            self.contentSize = contentSize
            self.content = content
            render()
        }

        private var scaledSize: CGSize {
            CGSize(width: contentSize.width * scale, height: contentSize.height * scale)
        }

        private func render() {
            hostingView.rootView = ScaledCanvas(size: contentSize, scale: scale, content: content())
            if hostingView.frame.size != scaledSize {
                hostingView.setFrameSize(scaledSize)
            }
        }

        /// 커서 아래의 캔버스 지점이 확대 전후에 같은 화면 위치에 있도록 스크롤 offset을 보정한다.
        func magnify(by delta: CGFloat, atWindowPoint windowPoint: NSPoint) {
            guard let scrollView else { return }
            let clipView = scrollView.contentView

            // NSHostingView는 flipped이므로 문서 좌표의 원점은 좌상단이다.
            let documentPoint = hostingView.convert(windowPoint, from: nil)
            let canvasPoint = CGPoint(x: documentPoint.x / scale, y: documentPoint.y / scale)
            let viewportOffset = CGPoint(x: documentPoint.x - clipView.bounds.minX,
                                         y: documentPoint.y - clipView.bounds.minY)

            let newScale = min(max(scale * (1 + delta), Self.magnificationRange.lowerBound),
                               Self.magnificationRange.upperBound)
            guard newScale != scale else { return }
            scale = newScale
            render()

            let maxOrigin = CGPoint(x: max(0, scaledSize.width - clipView.bounds.width),
                                    y: max(0, scaledSize.height - clipView.bounds.height))
            let origin = CGPoint(
                x: min(max(canvasPoint.x * scale - viewportOffset.x, 0), maxOrigin.x),
                y: min(max(canvasPoint.y * scale - viewportOffset.y, 0), maxOrigin.y)
            )
            clipView.scroll(to: origin)
            scrollView.reflectScrolledClipView(clipView)
        }
    }
}

/// 핀치(`magnify`) 이벤트를 바깥으로 넘기는 `NSScrollView`. 스크롤은 기본 동작을 그대로 쓴다.
final class CanvasNSScrollView: NSScrollView {
    var onMagnify: ((CGFloat, NSPoint) -> Void)?

    override func magnify(with event: NSEvent) {
        onMagnify?(event.magnification, event.locationInWindow)
    }
}
