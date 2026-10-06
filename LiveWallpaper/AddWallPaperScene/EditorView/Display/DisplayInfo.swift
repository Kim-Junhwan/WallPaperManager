//
//  MonitorInfo.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/3/26.
//

import Foundation
import CoreGraphics

struct DisplayInfo {
    let name: String
    let id: CGDirectDisplayID
    let resolutionWidth: Int
    let resolutionHeight: Int
    let origin: CGPoint
    let isPrimary: Bool
}
