//
//  Utils.swift
//  LiveWallpaper
//


import AVFoundation
import AppKit

func normalize(_ str:String) -> String {
    str.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}


func encodeParameters(_ params: [String: String]) -> String {
    return params
        .map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(encodedKey)=\(encodedValue)"
        }
        .joined(separator: "&")
}

func encodeParam(_ param:String) -> String {
    return param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}

func getAppSupportDirectory() -> URL {
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let appDirectory = url.appendingPathComponent("Wallpapers")
    try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
    return appDirectory
}

func recreateAppDataFolder() throws {
    let path = getAppSupportDirectory().path
    let fileManager = FileManager.default
    
    // Check if directory exists
    if fileManager.fileExists(atPath: path) {
        do {
            // Remove the directory and its contents
            try fileManager.removeItem(atPath: path)
        } catch {
            throw NSError(domain: "ResetDirectoryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete directory: \(error)"])
        }
    }
    
    do {
        // Recreate the directory
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch {
        throw NSError(domain: "ResetDirectoryError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create directory: \(error)"])
    }
}

func appDisplayName() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
}

func fnv1aHash(_ input: String) -> UInt64 {
    let prime: UInt64 = 1099511628211
    var hash: UInt64 = 14695981039346656037
    
    for byte in input.utf8 {
        hash ^= UInt64(byte)
        hash &*= prime  // Use wrapping multiply for efficiency
    }
    
    return hash
}


func downloadImage(url: URL, filename: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let fileManager = FileManager.default
    
    let appSupportDir = getAppSupportDirectory()
    
    let destinationURL = appSupportDir.appendingPathComponent(filename)
    
    // Check if file already exists
    if fileManager.fileExists(atPath: destinationURL.path) {
        completion(.success(destinationURL))
        return
    }
    
    // Download the file
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "DownloadError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            // Ensure directory exists
            if !fileManager.fileExists(atPath: appSupportDir.path) {
                try fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Write file
            try data.write(to: destinationURL)
            completion(.success(destinationURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}

func copyFile(fileURL: URL, targetFilename: String) async throws -> URL {
    let fileManager = FileManager.default
    
    
    // Create a subdirectory for the app
    let appSupportPath = getAppSupportDirectory()
    
    return try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global(qos: .utility).async {
            do {
                // Ensure the directory exists
                if !fileManager.fileExists(atPath: appSupportPath.path) {
                    try fileManager.createDirectory(at: appSupportPath, withIntermediateDirectories: true, attributes: nil)
                }
                
                // Extract file extension and append it if missing
                let fileExtension = fileURL.pathExtension
                let finalFilename = fileExtension.isEmpty ? targetFilename : "\(targetFilename).\(fileExtension)"
                
                // Define the destination path
                let destinationURL = appSupportPath.appendingPathComponent(finalFilename)
                
                // Always overwrite the file if it exists
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Copy the file
                try fileManager.copyItem(at: fileURL, to: destinationURL)
                
                continuation.resume(returning: destinationURL)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

func fileExists(at url: URL) -> Bool {
    return FileManager.default.fileExists(atPath: url.path)
}

func isValidMovieFile(at url: URL) -> Bool {
    let fileManager = FileManager.default
    
    // 1. Check if file exists
    guard fileManager.fileExists(atPath: url.path) else {
        return false
    }
    
    // 2. Check if file is a valid movie type
    guard let fileType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType else {
        return false
    }
    
    return fileType.conforms(to: .mpeg4Movie) || fileType.conforms(to: .quickTimeMovie)
}


func showErrorDialog(message: String, informativeText: String = "") {
    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = informativeText
    alert.alertStyle = .critical
    alert.addButton(withTitle: "OK")
    
    if let window = NSApplication.shared.keyWindow {
        alert.beginSheetModal(for: window, completionHandler: nil)
    } else {
        alert.runModal()
    }
}
