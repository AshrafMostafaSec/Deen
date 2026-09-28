import Foundation

public struct AdhkarItem: Identifiable, Codable, Sendable {
    public let id: String
    public let textArabic: String
    public let textEnglish: String
    public let targetCount: Int
    public let reference: String
    
    public init(id: String, textArabic: String, textEnglish: String, targetCount: Int, reference: String) {
        self.id = id
        self.textArabic = textArabic
        self.textEnglish = textEnglish
        self.targetCount = targetCount
        self.reference = reference
    }
}

public struct AdhkarFortressCatalog: Codable, Sendable {
    public let morning: [AdhkarItem]
    public let evening: [AdhkarItem]
    public let post_prayer: [AdhkarItem]
    public let sleep: [AdhkarItem]
    
    public init(
        morning: [AdhkarItem] = [],
        evening: [AdhkarItem] = [],
        post_prayer: [AdhkarItem] = [],
        sleep: [AdhkarItem] = []
    ) {
        self.morning = morning
        self.evening = evening
        self.post_prayer = post_prayer
        self.sleep = sleep
    }
    
    public func items(for categoryId: String) -> [AdhkarItem] {
        switch categoryId {
        case "morning": return morning
        case "evening": return evening
        case "post_prayer": return post_prayer
        case "sleep": return sleep
        default: return []
        }
    }
}
