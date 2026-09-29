import Foundation

public enum RadioCategory: String, Codable, Sendable, Equatable {
    case quran = "quran"
    case general = "general"
    case commercial = "commercial"
}

public enum RadioStreamFormat: String, Codable, Sendable, Equatable {
    case mp3 = "mp3"
    case aac = "aac"
    case hls = "hls"
}

public struct RadioStreamCandidate: Codable, Sendable, Equatable {
    public let url: URL
    public let format: RadioStreamFormat
    public let priority: Int
    
    public init(url: URL, format: RadioStreamFormat, priority: Int) {
        self.url = url
        self.format = format
        self.priority = priority
    }
}

public struct RadioStation: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let shortName: String?
    public let frequencyMHz: Double?
    public let category: RadioCategory
    public let countryCode: String
    public let city: String?
    public let artworkURL: URL?
    public let streamCandidates: [RadioStreamCandidate]
    public let isFeatured: Bool
    public let isEnabled: Bool
    
    public init(
        id: String,
        name: String,
        shortName: String? = nil,
        frequencyMHz: Double? = nil,
        category: RadioCategory,
        countryCode: String = "EG",
        city: String? = nil,
        artworkURL: URL? = nil,
        streamCandidates: [RadioStreamCandidate],
        isFeatured: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.frequencyMHz = frequencyMHz
        self.category = category
        self.countryCode = countryCode
        self.city = city
        self.artworkURL = artworkURL
        self.streamCandidates = streamCandidates
        self.isFeatured = isFeatured
        self.isEnabled = isEnabled
    }
}

public struct RadioCatalog: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let generatedAt: String
    public let stations: [RadioStation]
}
