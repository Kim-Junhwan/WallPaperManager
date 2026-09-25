//
//  DropViewModel.swift
//  LiveWallpaper
//
//  Created by Kimjunhwan on 9/22/26.
//

import Foundation
import UniformTypeIdentifiers
import AVFoundation
import AppKit

enum UploadAssetState {
    case empty
    case loading
    case loaded(WallpaperAsset)
}

enum AssetUploadError: Error {
    case notFoundFile
    case failedGenerateThumbnail
}

@MainActor
@Observable
class UploadAssetwModel {

    var state: UploadAssetState = .empty

    func uploadAsset(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            for supportType in AppConstant.supportAssetType {
                if provider.hasItemConformingToTypeIdentifier(supportType.identifier) {
                    uploadAssetAtFileSystem(provider: provider, supportType: supportType)
                    return true
                }
            }
        }
        return false
    }

    private func uploadAssetAtFileSystem(provider: NSItemProvider, supportType: UTType) {
        Task {
            do {
                state = .loading
                let type: MediaContent
                let (saveAssetURL, fileName) = try await copyAndSaveAsset(provider, type: supportType)
                let thumbUrl: URL
                if AppConstant.supportMovieType.contains(supportType) {
                    thumbUrl = try await generateMovieThumbnail(movieUrl: saveAssetURL, fileName: fileName)
                    type = .video(.default)
                } else {
                    thumbUrl = try generateImageThumbnail(imageUrl: saveAssetURL, fileName: fileName)
                    type = .image(.default)
                }
                state = .loaded(
                    WallpaperAsset(id: fileName, url: saveAssetURL.path(percentEncoded: false), type: type, thumbnail: thumbUrl.path(percentEncoded: false), createdAt: Date())
                )
            } catch {

            }
        }
    }

    private func copyAndSaveAsset(_ provider: NSItemProvider, type: UTType) async throws -> (fileUrl: URL, fileName: String) {
        return try await withCheckedThrowingContinuation { continuation in
            let _ = provider.loadFileRepresentation(for: type) { fileUrl, _, error in
                guard let fileUrl, error == nil else { return }
                let fileManager = FileManager.default
                let supportPath = getAppSupportDirectory()
                do {
                    let fileName = UUID().uuidString
                    let contentType = try fileUrl.resourceValues(forKeys: [.contentTypeKey]).contentType
                    var destinationURL = supportPath.appendingPathComponent(fileName)
                    if let contentType {
                        destinationURL.appendPathExtension(for: contentType)
                    }

                    if fileManager.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.copyItem(at: fileUrl, to: destinationURL)
                    continuation.resume(returning: (destinationURL, fileName))
                } catch {
                    continuation.resume(throwing: error)
                }

            }
        }

    }

    private func generateMovieThumbnail(movieUrl: URL, fileName: String) async throws -> URL {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: movieUrl.path(percentEncoded: false)) else { throw AssetUploadError.notFoundFile }
        let asset = AVURLAsset(url: movieUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 600, height: 450)

        imageGenerator.requestedTimeToleranceBefore = .positiveInfinity
        imageGenerator.requestedTimeToleranceAfter = .positiveInfinity

        let duration = try await asset.load(.duration)
        let durationSeconds = CMTimeGetSeconds(duration)

        let targetTimeSeconds = durationSeconds < 3.0 ? durationSeconds / 2.0 : durationSeconds / 3.0
        let targetTime = CMTime(seconds: max(0, targetTimeSeconds), preferredTimescale: 600)

        let cgImage = try await imageGenerator.image(at: targetTime).image
        let thumbnail = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        guard let imageData = thumbnail.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: imageData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw AssetUploadError.failedGenerateThumbnail
        }

        var thumbUrl = getAppSupportDirectory().appendingPathComponent(fileName)
        thumbUrl.appendPathExtension(for: .png)

        if fileManager.fileExists(atPath: thumbUrl.path(percentEncoded: false)) {
            try fileManager.removeItem(at: thumbUrl)
        }

        try pngData.write(to: thumbUrl, options: .atomic)
        return thumbUrl
    }

    private func generateImageThumbnail(imageUrl: URL, fileName: String) throws -> URL {
        guard let source = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) else { throw AssetUploadError.failedGenerateThumbnail }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: 600
        ]

        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { throw AssetUploadError.failedGenerateThumbnail }

        let bitmap = NSBitmapImageRep(cgImage: thumbnail)
        guard let pngData = bitmap.representation(using: .png, properties: [:]) else { throw AssetUploadError.failedGenerateThumbnail }
        var destinationUrl = getAppSupportDirectory().appendingPathComponent(fileName)
        destinationUrl.appendPathExtension(for: .png)
        try pngData.write(to: destinationUrl, options: .atomic)

        return destinationUrl
    }
}
