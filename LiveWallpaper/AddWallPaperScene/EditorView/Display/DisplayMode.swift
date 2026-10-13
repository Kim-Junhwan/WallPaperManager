//
//  DisplayMode.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 10/3/26.
//

import Foundation

enum DisplayMode {
    case idle
    case single(display: DisplayInfo)
    case perDisplay
    case spanAll
}
