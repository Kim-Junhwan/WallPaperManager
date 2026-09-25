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
                    uploadAsset(from: provider, supportType: supportType)
                    return true
                }
            }
        }
        return false
    }

    func uploadAsset(_ url: URL) {
        guard let contentType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType,
              let supportType = AppConstant.supportAssetType.first(where: { contentType.conforms(to: $0) }) else {
            return
        }

        state = .loading
        Task {
            do {
                let savedAsset = try await Task.detached(priority: .userInitiated) {
                    try Self.copyAndSaveAsset(url)
                }.value
                try await finishUploading(savedAsset, supportType: supportType)
            } catch {
                state = .empty
            }
        }
    }

    private func uploadAsset(from provider: NSItemProvider, supportType: UTType) {
        state = .loading

        _ = provider.loadFileRepresentation(for: supportType) { [weak self] fileURL, _, error in
            guard error == nil, let fileURL else {
                Task { @MainActor [weak self] in
                    self?.state = .empty
                }
                return
            }

            do {
                // The provider may remove this temporary file when the callback returns.
                let savedAsset = try Self.copyAndSaveAsset(fileURL)
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        try await finishUploading(savedAsset, supportType: supportType)
                    } catch {
                        state = .empty
                    }
                }
            } catch {
                Task { @MainActor [weak self] in
                    self?.state = .empty
                }
            }
        }
    }

    private nonisolated static func copyAndSaveAsset(_ url: URL) throws -> (fileUrl: URL, fileName: String) {
        let didAccessSecurityScopedResource = url.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default
        let supportPath = getAppSupportDirectory()
        let fileName = UUID().uuidString
        let contentType = try url.resourceValues(forKeys: [.contentTypeKey]).contentType
        var destinationURL = supportPath.appendingPathComponent(fileName)
        if let contentType {
            destinationURL.appendPathExtension(for: contentType)
        }

        if fileManager.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: url, to: destinationURL)
        return (destinationURL, fileName)
    }

    private func finishUploading(
        _ savedAsset: (fileUrl: URL, fileName: String),
        supportType: UTType
    ) async throws {
        let type: MediaContent
        let thumbUrl: URL

        if AppConstant.supportMovieType.contains(supportType) {
            thumbUrl = try await generateMovieThumbnail(
                movieUrl: savedAsset.fileUrl,
                fileName: savedAsset.fileName
            )
            type = .video(.default)
        } else {
            thumbUrl = try generateImageThumbnail(
                imageUrl: savedAsset.fileUrl,
                fileName: savedAsset.fileName
            )
            type = .image(.default)
        }

        state = .loaded(
            WallpaperAsset(
                id: savedAsset.fileName,
                url: savedAsset.fileUrl.path(percentEncoded: false),
                type: type,
                thumbnail: thumbUrl.path(percentEncoded: false),
                createdAt: Date()
            )
        )
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
