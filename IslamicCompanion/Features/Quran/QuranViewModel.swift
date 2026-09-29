import SwiftUI
import Observation

public enum QuranTabFilter: String, CaseIterable, Identifiable, Sendable {
    case surahs = "Surahs"
    case juz = "Juz"
    case bookmarks = "Bookmarks"
    
    public var id: String { rawValue }
    
    public var arabicName: String {
        switch self {
        case .surahs: return "السور"
        case .juz: return "الأجزاء"
        case .bookmarks: return "العلامات المرجعية"
        }
    }
}

public struct JuzItem: Identifiable, Sendable {
    public var id: Int { number }
    public let number: Int
    public let nameArabic: String
    public let startingSurahName: String
    public let startPage: Int
}

@MainActor
@Observable
public final class QuranViewModel {
    public var selectedFilter: QuranTabFilter = .surahs
    public var searchText: String = ""
    
    // Last read bookmark
    public var lastReadSurah: String = "Al-Kahf"
    public var lastReadSurahArabic: String = "سورة الكهف"
    public var lastReadPage: Int = 293
    public var lastReadJuz: Int = 15
    public var lastReadAyah: Int = 1
    public var overallProgressPercentage: Int = 12
    
    // Active Audio highlight
    public var featuredReciterName: String = "Mishary Rashid Al-Afasy"
    public var featuredSurahName: String = "Surah Al-Kahf"
    
    public var isFeaturedPlaying: Bool {
        if case .quran(let surahName, _, _) = AudioService.shared.currentSource {
            return surahName.contains("Al-Kahf") && AudioService.shared.isPlaying
        }
        return false
    }
    
    public private(set) var surahs: [SurahMetadata] = []
    
    public let juzList: [JuzItem] = (1...30).map { i in
        JuzItem(number: i, nameArabic: "الجزء \(i)", startingSurahName: i == 1 ? "Al-Fatihah" : "Juz \(i)", startPage: (i - 1) * 20 + 2)
    }
    
    public init() {
        self.surahs = Self.loadSurahs()
    }
    
    private static func loadSurahs() -> [SurahMetadata] {
        if let url = Bundle.main.url(forResource: "surahs_114", withExtension: "json") ??
                     Bundle.main.url(forResource: "surahs_114", withExtension: "json", subdirectory: "Quran"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([SurahMetadata].self, from: data),
           !decoded.isEmpty {
            return decoded
        }
        return fallbackSurahs
    }
    
    public var filteredSurahs: [SurahMetadata] {
        if searchText.isEmpty {
            return surahs
        } else {
            let normalizedQuery = normalizeArabic(searchText.lowercased())
            return surahs.filter {
                $0.nameEnglish.localizedCaseInsensitiveContains(searchText) ||
                normalizeArabic($0.nameArabic).contains(normalizedQuery) ||
                "\($0.number)".contains(searchText)
            }
        }
    }
    
    public func toggleFeaturedAudio() {
        if isFeaturedPlaying {
            AudioService.shared.togglePlayPause()
        } else {
            if let url = URL(string: "https://everyayah.com/data/Alafasy_128kbps/018001.mp3") {
                AudioService.shared.playQuranAudio(
                    surahName: "Surah Al-Kahf",
                    reciterName: featuredReciterName,
                    audioURL: url,
                    ayahNumber: 1
                )
            }
        }
    }
    
    private func normalizeArabic(_ text: String) -> String {
        var str = text
        let map: [(String, String)] = [
            ("أ", "ا"), ("إ", "ا"), ("آ", "ا"), ("ٱ", "ا"),
            ("ة", "ه"), ("ى", "ي"),
            ("َ", ""), ("ُ", ""), ("ِ", ""), ("ً", ""), ("ٌ", ""), ("ٍ", ""), ("ّ", ""), ("ْ", "")
        ]
        for (from, to) in map {
            str = str.replacingOccurrences(of: from, with: to)
        }
        return str
    }
    
    nonisolated public static let fallbackSurahs: [SurahMetadata] = [
        SurahMetadata(number: 1, nameArabic: "الفاتحة", nameEnglish: "Al-Fatihah", englishTranslation: "The Opening", totalAyahs: 7, revelationType: .makkah, startPage: 1, juzNumber: 1),
        SurahMetadata(number: 2, nameArabic: "البقرة", nameEnglish: "Al-Baqarah", englishTranslation: "The Cow", totalAyahs: 286, revelationType: .madinah, startPage: 2, juzNumber: 1),
        SurahMetadata(number: 3, nameArabic: "آل عمران", nameEnglish: "Ali 'Imran", englishTranslation: "Family of Imran", totalAyahs: 200, revelationType: .madinah, startPage: 50, juzNumber: 3),
        SurahMetadata(number: 4, nameArabic: "النساء", nameEnglish: "An-Nisa", englishTranslation: "The Women", totalAyahs: 176, revelationType: .madinah, startPage: 77, juzNumber: 4),
        SurahMetadata(number: 5, nameArabic: "المائدة", nameEnglish: "Al-Ma'idah", englishTranslation: "The Table Spread", totalAyahs: 120, revelationType: .madinah, startPage: 106, juzNumber: 6),
        SurahMetadata(number: 6, nameArabic: "الأنعام", nameEnglish: "Al-An'am", englishTranslation: "The Cattle", totalAyahs: 165, revelationType: .makkah, startPage: 128, juzNumber: 7),
        SurahMetadata(number: 7, nameArabic: "الأعراف", nameEnglish: "Al-A'raf", englishTranslation: "The Heights", totalAyahs: 206, revelationType: .makkah, startPage: 151, juzNumber: 8),
        SurahMetadata(number: 8, nameArabic: "الأنفال", nameEnglish: "Al-Anfal", englishTranslation: "The Spoils of War", totalAyahs: 75, revelationType: .madinah, startPage: 177, juzNumber: 9),
        SurahMetadata(number: 9, nameArabic: "التوبة", nameEnglish: "At-Tawbah", englishTranslation: "The Repentance", totalAyahs: 129, revelationType: .madinah, startPage: 187, juzNumber: 10),
        SurahMetadata(number: 10, nameArabic: "يونس", nameEnglish: "Yunus", englishTranslation: "Jonah", totalAyahs: 109, revelationType: .makkah, startPage: 208, juzNumber: 11),
        SurahMetadata(number: 18, nameArabic: "الكهف", nameEnglish: "Al-Kahf", englishTranslation: "The Cave", totalAyahs: 110, revelationType: .makkah, startPage: 293, juzNumber: 15),
        SurahMetadata(number: 36, nameArabic: "يس", nameEnglish: "Ya-Sin", englishTranslation: "Ya-Sin", totalAyahs: 83, revelationType: .makkah, startPage: 440, juzNumber: 22),
        SurahMetadata(number: 55, nameArabic: "الرحمن", nameEnglish: "Ar-Rahman", englishTranslation: "The Beneficent", totalAyahs: 78, revelationType: .madinah, startPage: 531, juzNumber: 27),
        SurahMetadata(number: 56, nameArabic: "الواقعة", nameEnglish: "Al-Waqi'ah", englishTranslation: "The Inevitable", totalAyahs: 96, revelationType: .makkah, startPage: 534, juzNumber: 27),
        SurahMetadata(number: 67, nameArabic: "الملك", nameEnglish: "Al-Mulk", englishTranslation: "The Sovereignty", totalAyahs: 30, revelationType: .makkah, startPage: 562, juzNumber: 29),
        SurahMetadata(number: 112, nameArabic: "الإخلاص", nameEnglish: "Al-Ikhlas", englishTranslation: "Sincerity", totalAyahs: 4, revelationType: .makkah, startPage: 604, juzNumber: 30),
        SurahMetadata(number: 113, nameArabic: "الفلق", nameEnglish: "Al-Falaq", englishTranslation: "Daybreak", totalAyahs: 5, revelationType: .makkah, startPage: 604, juzNumber: 30),
        SurahMetadata(number: 114, nameArabic: "الناس", nameEnglish: "An-Nas", englishTranslation: "Mankind", totalAyahs: 6, revelationType: .makkah, startPage: 604, juzNumber: 30)
    ]
}
