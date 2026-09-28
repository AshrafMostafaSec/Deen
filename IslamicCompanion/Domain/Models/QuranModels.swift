import Foundation

public enum RevelationType: String, Codable, Sendable {
    case makkah = "Makki"
    case madinah = "Madani"
    
    public var arabicName: String {
        switch self {
        case .makkah: return "مكية"
        case .madinah: return "مدنية"
        }
    }
}

public struct SurahMetadata: Identifiable, Codable, Sendable {
    public let number: Int
    public let nameArabic: String
    public let nameEnglish: String
    public let englishTranslation: String
    public let totalAyahs: Int
    public let revelationType: RevelationType
    public let startPage: Int
    public let juzNumber: Int
    
    public var id: Int { number }
    
    public init(
        number: Int,
        nameArabic: String,
        nameEnglish: String,
        englishTranslation: String,
        totalAyahs: Int,
        revelationType: RevelationType,
        startPage: Int,
        juzNumber: Int
    ) {
        self.number = number
        self.nameArabic = nameArabic
        self.nameEnglish = nameEnglish
        self.englishTranslation = englishTranslation
        self.totalAyahs = totalAyahs
        self.revelationType = revelationType
        self.startPage = startPage
        self.juzNumber = juzNumber
    }
}

public struct AyahItem: Identifiable, Codable, Sendable {
    public let surahNumber: Int
    public let ayahNumber: Int
    public let textArabic: String
    public let textEnglish: String?
    public let page: Int
    public let juz: Int
    
    public var id: String { "\(surahNumber):\(ayahNumber)" }
    
    public init(
        surahNumber: Int,
        ayahNumber: Int,
        textArabic: String,
        textEnglish: String? = nil,
        page: Int,
        juz: Int
    ) {
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.textArabic = textArabic
        self.textEnglish = textEnglish
        self.page = page
        self.juz = juz
    }
}

public struct QuranReadingBookmark: Codable, Sendable {
    public let surahNumber: Int
    public let ayahNumber: Int
    public let pageNumber: Int
    public let juzNumber: Int
    public let updatedAt: Date
    
    public init(surahNumber: Int, ayahNumber: Int, pageNumber: Int, juzNumber: Int, updatedAt: Date = Date()) {
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.pageNumber = pageNumber
        self.juzNumber = juzNumber
        self.updatedAt = updatedAt
    }
}
