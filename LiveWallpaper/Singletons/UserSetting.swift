//
//  UserSetting.swift
//  LiveWallpaper
//


import Foundation

struct WallpaperAsset: Codable, Equatable, Hashable {
    let id:String
    let url:URL
    let type:MediaContent
    let thumbnail:URL
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, url, type, thumbnail, createdAt
    }
}

struct ImageMetaData: Codable, Hashable {

    static let `default` = ImageMetaData()
}

struct VideoMetaData: Codable, Hashable {
    let brightness: Double
    let saturation: Double
    let warmth: Double

    static let `default` = VideoMetaData(brightness: 0.2, saturation: 0.5, warmth: 0.0)

    var unpacked: (Double, Double, Double) {
        (brightness, saturation, warmth)
    }
}


enum MediaContent: Codable, Hashable {
    case image(ImageMetaData)
    case video(VideoMetaData)
}


struct Sound: Codable {
    var name:String
    var isEnabled: Bool
    var volume: Float
}

class UserSetting: ObservableObject, @unchecked Sendable {
    static let shared = UserSetting()
    
    @Published var video:WallpaperAsset?
    @Published var recent:[WallpaperAsset] = []
    
    @Published var mixerEnabled = false {
        didSet {
            defaults.set(mixerEnabled, forKey: "mixerEnabled")
            AudioMixer.shared.process(mixerEnabled: mixerEnabled, sounds: sounds)
        }
    }
    
    @Published var sounds:[Sound] = [] {
        didSet {
            print("sounds did set")
            if let encoded = try? JSONEncoder().encode(sounds) {
                defaults.set(encoded, forKey: "sounds")
            }
            AudioMixer.shared.process(mixerEnabled: mixerEnabled, sounds: sounds)
        }
    }
    
    @Published var launchAtLogin = false {
        didSet {
            defaults.set(launchAtLogin, forKey: "launchAtLogin")
        }
    }
    
    @Published var doNotShowWindow = false {
        didSet {
            defaults.set(doNotShowWindow, forKey: "doNotShowWindow")
        }
    }
    
    @Published var powerSaver = false {
        didSet {
            defaults.set(powerSaver, forKey: "powerSaver")
        }
    }

    static let pauseOnFocusLossChangedNotification = Notification.Name("UserSetting.pauseOnFocusLossChanged")

    @Published var pauseOnFocusLoss = false {
        didSet {
            defaults.set(pauseOnFocusLoss, forKey: "pauseOnFocusLoss")
            NotificationCenter.default.post(name: Self.pauseOnFocusLossChangedNotification, object: nil)
        }
    }
    
    static let adaptiveModeChangedNotification = Notification.Name("UserSetting.adaptiveModeChanged")

    @Published var adaptiveMode: Bool = false {
        didSet {
            defaults.set(adaptiveMode, forKey: "adaptiveMode")
            NotificationCenter.default.post(name: Self.adaptiveModeChangedNotification, object: nil)
        }
    }
    
    var attemptId = ""
    
    private let defaults = UserDefaults.standard
    
    init(){
        self.video = getVideo()
        self.recent = getRecent()
        self.mixerEnabled = getMixerEnabled()
        self.sounds = getSounds()
        self.launchAtLogin = getlaunchAtLogin()
        self.doNotShowWindow = getdoNotShowWindow()
        self.powerSaver = getPowerSaver()
        self.pauseOnFocusLoss = defaults.bool(forKey: "pauseOnFocusLoss")

        self.adaptiveMode = defaults.bool(forKey: "adaptiveMode")
    }
    
    func setVideo(_ video: WallpaperAsset) {
        if let encoded = try? JSONEncoder().encode(video) {
            defaults.set(encoded, forKey: "video")
            self.video = video
        }
        
        var recent = getRecent()
        if !recent.contains(video) {
            recent.append(video)
            if let encoded = try? JSONEncoder().encode(recent) {
                defaults.set(encoded, forKey: "recent")
                self.recent = recent
            }
        }
    }
    
    func deleteVideo(_ video: WallpaperAsset){
        recent.removeAll {$0.id == video.id}
        if let encoded = try? JSONEncoder().encode(recent) {
            defaults.set(encoded, forKey: "recent")
            self.recent = recent
        }
        
        do {
            try FileManager.default.removeItem(atPath: video.url.path(percentEncoded: false))
            try FileManager.default.removeItem(atPath: video.thumbnail.path(percentEncoded: false))
        } catch {}
        
    }
    
    func resetVideoAndRecent(){
        video = nil
        recent = []
        if let encoded = try? JSONEncoder().encode(video) {
            defaults.set(encoded, forKey: "video")
        }
        if let encoded = try? JSONEncoder().encode(recent) {
            defaults.set(encoded, forKey: "recent")
        }
    }
    
    func getVideo() -> WallpaperAsset? {
        if let savedData = defaults.data(forKey: "video"),
           let video = try? JSONDecoder().decode(WallpaperAsset.self, from: savedData) {
            return video
        }
        return nil
    }
    
    func getRecent() -> [WallpaperAsset] {
        if let savedData = defaults.data(forKey: "recent"),
           let videos = try? JSONDecoder().decode([WallpaperAsset].self, from: savedData) {
            return videos
        }
        return []
    }
    
    func getMixerEnabled() -> Bool {
        return defaults.bool(forKey: "mixerEnabled")
    }
    
    func getlaunchAtLogin() -> Bool {
        return defaults.bool(forKey: "launchAtLogin")
    }
    
    func getdoNotShowWindow() -> Bool {
        return defaults.bool(forKey: "doNotShowWindow")
    }
    
    func getPowerSaver() -> Bool {
        return defaults.bool(forKey: "powerSaver")
    }
    
    func getSounds() -> [Sound] {
        if let savedData = defaults.data(forKey: "sounds"),
           let sounds = try? JSONDecoder().decode([Sound].self, from: savedData) {
            return sounds
        }
        
        let mp3s = [
            "rain","thunder","fire", "beach", "seagull",
            "wind", "bird", "creek", "cricket", "snow",
            "firework", "foghorn","fan", "owls", "palm",
            "playground", "coffee", "restaurant",
             "train",  "wolves", "bowl", "chimes",
        ]
        
        for mp3 in mp3s {
            sounds.append(Sound(name: mp3, isEnabled: false, volume: 0.5))
        }
        return sounds
    }
    
    

}
