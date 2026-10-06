//
//  DisplayManager.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/3/26.
//

import Foundation
import CoreGraphics
import AppKit

enum DisplayError: Error {
    case displayNotFound(CGError)
}

enum DisplayManager {

    static func getDisplayInfos() throws -> [DisplayInfo] {
        var count: UInt32 = 0
        let displayCountError = CGGetOnlineDisplayList(0, nil, &count)

        guard displayCountError == .success else { throw DisplayError.displayNotFound(displayCountError) }

        var displays: [CGDirectDisplayID] = .init(repeating: 0, count: Int(count))
        let getDisplayError = CGGetOnlineDisplayList(count, &displays, nil)

        guard getDisplayError == .success else { throw DisplayError.displayNotFound(getDisplayError) }

        let displayMode = displays.map { (CGDisplayCopyDisplayMode($0), $0) }.compactMap { (a, b) -> (CGDisplayMode, CGDirectDisplayID)? in
            guard let a else { return nil }
            return (a, b)
        }
        return displayMode.map { mode, id in
            
            return .init(
                name: getDisplayName(for: id) ?? "Unknown",
                id: id,
                resolutionWidth: mode.width,
                resolutionHeight: mode.height,
                origin:  CGDisplayBounds(id).origin,
                isPrimary: CGDisplayIsMain(id) != 0
            )
        }
    }

    static func getDisplayName(for displayId: CGDirectDisplayID) -> String? {
        for screen in NSScreen.screens {
            if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID, screenNumber == displayId {
                return screen.localizedName
            }
        }
        return nil
    }
}
