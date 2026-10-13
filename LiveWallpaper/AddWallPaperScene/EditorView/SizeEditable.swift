//
//  SizeEditable.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/5/26.
//

import SwiftUI

// MARK: - Handle

private enum Axis { case x, y }

/// 크기 조절 핸들의 위치. 변(edge) 4개 + 꼭짓점(corner) 4개.
enum ResizeHandle: CaseIterable {
    case topLeading, top, topTrailing
    case leading, trailing
    case bottomLeading, bottom, bottomTrailing

    var isCorner: Bool {
        switch self {
        case .topLeading, .topTrailing, .bottomLeading, .bottomTrailing: true
        default: false
        }
    }

    /// 핸들이 영향을 주는 변. (-1: 왼쪽/위, 0: 영향 없음, 1: 오른쪽/아래)
    fileprivate var direction: (x: Int, y: Int) {
        switch self {
        case .topLeading: (-1, -1)
        case .top: (0, -1)
        case .topTrailing: (1, -1)
        case .leading: (-1, 0)
        case .trailing: (1, 0)
        case .bottomLeading: (-1, 1)
        case .bottom: (0, 1)
        case .bottomTrailing: (1, 1)
        }
    }

    /// 뷰 크기 안에서의 핸들 중심 위치.
    fileprivate func position(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * (CGFloat(direction.x) + 1) / 2,
                y: size.height * (CGFloat(direction.y) + 1) / 2)
    }

    /// 드래그 시작 시점의 rect에 translation을 적용한 새 rect.
    /// 반대편 변은 고정되며, 최소 크기와 bounds를 넘지 않는다.
    /// `keepAspect`가 true면 원래 비율을 유지한다. (꼭짓점: 반대 꼭짓점 고정, 변: 반대 변 고정 + 다른 축은 중앙 기준)
    fileprivate func resized(
        _ rect: CGRect,
        by t: CGSize,
        minSize: CGSize,
        bounds: CGRect?,
        keepAspect: Bool = false
    ) -> CGRect {
        guard keepAspect, rect.width > 0, rect.height > 0 else {
            return freeResized(rect, by: t, minSize: minSize, bounds: bounds)
        }

        // 제약 없이 움직였을 때의 배율을 기준으로 균일 배율을 정한다.
        let raw = freeResized(rect, by: t, minSize: .zero, bounds: nil)
        let sx = raw.width / rect.width
        let sy = raw.height / rect.height
        var scale: CGFloat = switch (direction.x, direction.y) {
        case (_, 0): sx
        case (0, _): sy
        default: abs(sx - 1) > abs(sy - 1) ? sx : sy
        }

        // 최소 크기 / bounds로 배율 제한
        let lower = max(minSize.width / rect.width, minSize.height / rect.height)
        var upper = CGFloat.infinity
        if let bounds {
            upper = min(
                availableExtent(axis: .x, rect: rect, bounds: bounds) / rect.width,
                availableExtent(axis: .y, rect: rect, bounds: bounds) / rect.height
            )
        }
        scale = max(lower, min(scale, upper))

        let w = rect.width * scale, h = rect.height * scale
        let x = switch direction.x {
        case -1: rect.maxX - w
        case 1: rect.minX
        default: rect.midX - w / 2
        }
        let y = switch direction.y {
        case -1: rect.maxY - h
        case 1: rect.minY
        default: rect.midY - h / 2
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private func freeResized(_ rect: CGRect, by t: CGSize, minSize: CGSize, bounds: CGRect?) -> CGRect {
        var minX = rect.minX, maxX = rect.maxX
        var minY = rect.minY, maxY = rect.maxY

        switch direction.x {
        case -1: minX = min(max(minX + t.width, bounds?.minX ?? -.infinity), maxX - minSize.width)
        case 1: maxX = max(min(maxX + t.width, bounds?.maxX ?? .infinity), minX + minSize.width)
        default: break
        }
        switch direction.y {
        case -1: minY = min(max(minY + t.height, bounds?.minY ?? -.infinity), maxY - minSize.height)
        case 1: maxY = max(min(maxY + t.height, bounds?.maxY ?? .infinity), minY + minSize.height)
        default: break
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// 고정점(앵커) 기준으로 해당 축에서 늘어날 수 있는 최대 길이.
    private func availableExtent(axis: Axis, rect: CGRect, bounds: CGRect) -> CGFloat {
        let dir = axis == .x ? direction.x : direction.y
        let (lo, hi, mid, blo, bhi) = axis == .x
            ? (rect.minX, rect.maxX, rect.midX, bounds.minX, bounds.maxX)
            : (rect.minY, rect.maxY, rect.midY, bounds.minY, bounds.maxY)
        switch dir {
        case -1: return hi - blo
        case 1: return bhi - lo
        default: return 2 * min(mid - blo, bhi - mid)
        }
    }

    /// macOS 15 미만에서는 대각선 전용 공개 NSCursor가 없어 crosshair로 대체한다.
    fileprivate var legacyCursor: NSCursor {
        switch (direction.x, direction.y) {
        case (_, 0): .resizeLeftRight
        case (0, _): .resizeUpDown
        default: .crosshair
        }
    }
}

// MARK: - Modifier

/// 선택 시 테두리와 8방향 핸들을 보여주고, 드래그로 `frame`을 수정하는 modifier.
///
/// `frame`은 부모 좌표계(좌상단 원점)의 rect이다. modifier가 `position`/`frame`까지
/// 적용하므로 호출 쪽에서는 별도로 frame을 주지 않는다.
struct SizeEditableModifier: ViewModifier {
    @Binding var frame: CGRect
    @Binding var isSelected: Bool
    var minSize: CGSize
    var bounds: CGRect?

    private let handleDiameter: CGFloat = 12
    private let edgeThickness: CGFloat = 8

    @State private var dragStartFrame: CGRect?

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .contentShape(Rectangle())
            .onTapGesture { isSelected = true }
            .overlay { if isSelected { selectionOverlay } }
            .position(x: frame.midX, y: frame.midY)
    }

    private var selectionOverlay: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.accentColor, lineWidth: 1.5)
                .allowsHitTesting(false)

            // 변을 먼저 깔고 꼭짓점이 위에 오도록 순서를 고정한다.
            ForEach(ResizeHandle.allCases.filter { !$0.isCorner }, id: \.self, content: edgeHandle)
            ForEach(ResizeHandle.allCases.filter(\.isCorner), id: \.self, content: cornerHandle)
        }
    }

    private func edgeHandle(_ handle: ResizeHandle) -> some View {
        let horizontal = handle.direction.y == 0 // leading / trailing → 세로로 긴 영역
        return GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .frame(width: horizontal ? edgeThickness : geo.size.width,
                       height: horizontal ? geo.size.height : edgeThickness)
                .position(handle.position(in: geo.size))
                .resizeCursor(handle)
                .gesture(dragGesture(handle))
        }
    }

    private func cornerHandle(_ handle: ResizeHandle) -> some View {
        GeometryReader { geo in
            Circle()
                .fill(Color.white)
                .overlay(Circle().strokeBorder(Color.accentColor, lineWidth: 1.5))
                .frame(width: handleDiameter, height: handleDiameter)
                .contentShape(Circle().inset(by: -4))
                .position(handle.position(in: geo.size))
                .resizeCursor(handle)
                .gesture(dragGesture(handle))
        }
    }

    private func dragGesture(_ handle: ResizeHandle) -> some Gesture {
        // 핸들 자체가 움직이므로 로컬 좌표 대신 global 좌표의 translation을 쓴다.
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                let start = dragStartFrame ?? frame
                dragStartFrame = start
                // Shift는 드래그 중 매 이벤트마다 읽으므로 도중에 눌렀다 떼도 바로 반영된다.
                let keepAspect = NSEvent.modifierFlags.contains(.shift)
                frame = handle.resized(start, by: value.translation, minSize: minSize,
                                       bounds: bounds, keepAspect: keepAspect)
            }
            .onEnded { _ in dragStartFrame = nil }
    }
}

// MARK: - Cursor

private extension View {
    @ViewBuilder
    func resizeCursor(_ handle: ResizeHandle) -> some View {
        if #available(macOS 15, *) {
            self.pointerStyle(.frameResize(position: handle.framePosition))
        } else {
            self.onHover { inside in
                if inside { handle.legacyCursor.push() } else { NSCursor.pop() }
            }
        }
    }
}

@available(macOS 15, *)
private extension ResizeHandle {
    var framePosition: FrameResizePosition {
        switch self {
        case .topLeading: .topLeading
        case .top: .top
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .trailing: .trailing
        case .bottomLeading: .bottomLeading
        case .bottom: .bottom
        case .bottomTrailing: .bottomTrailing
        }
    }
}

// MARK: - API

extension View {
    /// 클릭하면 선택되고, 선택 상태에서 테두리/핸들로 크기를 조절할 수 있게 한다.
    /// - Parameters:
    ///   - frame: 부모 좌표계 기준 rect (양방향 바인딩).
    ///   - isSelected: 선택 상태. 해제는 호출 쪽(예: 배경 탭)에서 담당한다.
    ///   - minSize: 조절 가능한 최소 크기.
    ///   - bounds: 지정하면 이 영역 밖으로 나가지 않는다.
    func sizeEditable(
        frame: Binding<CGRect>,
        isSelected: Binding<Bool>,
        minSize: CGSize = CGSize(width: 40, height: 40),
        bounds: CGRect? = nil
    ) -> some View {
        modifier(SizeEditableModifier(frame: frame, isSelected: isSelected, minSize: minSize, bounds: bounds))
    }
}

// MARK: - ResizableView

/// 컨테이너 안에서 `content`를 선택/크기 조절할 수 있게 감싸는 뷰.
/// 배경을 클릭하면 선택이 해제된다.
struct ResizableView<Content: View>: View {
    @Binding var frame: CGRect
    var minSize: CGSize = CGSize(width: 40, height: 40)
    @ViewBuilder var content: () -> Content

    @State private var isSelected = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { isSelected = false }

                content()
                    .sizeEditable(frame: $frame,
                                  isSelected: $isSelected,
                                  minSize: minSize,
                                  bounds: CGRect(origin: .zero, size: geo.size))
            }
        }
    }
}

#Preview("ResizableView") {
    struct Demo: View {
        @State private var frame = CGRect(x: 120, y: 80, width: 260, height: 170)

        var body: some View {
            ResizableView(frame: $frame) {
                LinearGradient(colors: [.indigo, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(Text("\(Int(frame.width)) × \(Int(frame.height))")
                        .font(.title2.monospacedDigit())
                        .foregroundStyle(.white))
            }
            .frame(width: 640, height: 420)
            .background(Color.gray.opacity(0.15))
        }
    }
    return Demo()
}

// MARK: - Move

/// 본체를 드래그해 `frame.origin`을 옮기는 modifier. 크기는 바꾸지 않는다.
/// `sizeEditable`보다 **안쪽**에 붙여야 드래그 영역이 부모 전체로 퍼지지 않는다.
struct FrameMovableModifier: ViewModifier {
    @Binding var frame: CGRect
    @Binding var isSelected: Bool
    var bounds: CGRect?

    @State private var dragStartFrame: CGRect?

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .moveCursor(isActive: isSelected)
            .gesture(
                // 탭(선택)과 구분되도록 약간의 이동 거리 이후에 시작한다.
                DragGesture(minimumDistance: 3, coordinateSpace: .global)
                    .onChanged { value in
                        isSelected = true
                        let start = dragStartFrame ?? frame
                        dragStartFrame = start
                        var origin = CGPoint(x: start.minX + value.translation.width,
                                             y: start.minY + value.translation.height)
                        if let bounds {
                            origin.x = min(max(origin.x, bounds.minX), max(bounds.minX, bounds.maxX - start.width))
                            origin.y = min(max(origin.y, bounds.minY), max(bounds.minY, bounds.maxY - start.height))
                        }
                        frame.origin = origin
                    }
                    .onEnded { _ in dragStartFrame = nil }
            )
    }
}

private extension View {
    @ViewBuilder
    func moveCursor(isActive: Bool) -> some View {
        if #available(macOS 15, *), isActive {
            self.pointerStyle(.grabIdle)
        } else {
            self
        }
    }
}

extension View {
    /// 본체를 드래그해 `frame`의 위치를 옮긴다. 드래그를 시작하면 선택 상태가 된다.
    /// `sizeEditable`과 함께 쓸 때는 `.frameMovable(...)`을 먼저, `.sizeEditable(...)`을 나중에 붙인다.
    func frameMovable(
        frame: Binding<CGRect>,
        isSelected: Binding<Bool>,
        bounds: CGRect? = nil
    ) -> some View {
        modifier(FrameMovableModifier(frame: frame, isSelected: isSelected, bounds: bounds))
    }
}
