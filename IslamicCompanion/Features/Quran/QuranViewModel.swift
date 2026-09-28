import SwiftUI
import Observation

public enum QuranTabFilter: String, CaseIterable, Identifiable {
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

@MainActor
@Observable
public final class QuranViewModel {
    public var selectedFilter: QuranTabFilter = .surahs
    public var searchText: String = ""
    
    // Last read bookmark
    public var lastReadSurah: String = "Al-Baqarah"
    public var lastReadSurahArabic: String = "سورة البقرة"
    public var lastReadPage: Int = 28
    public var lastReadJuz: Int = 2
    public var lastReadAyah: Int = 183
    public var overallProgressPercentage: Int = 5
    
    // Active Audio highlight
    public var featuredReciterName: String = "Mishary Rashid Al-Afasy"
    public var featuredSurahName: String = "Surah Al-Kahf"
    public var isFeaturedPlaying: Bool = false
    
    public let surahs: [SurahMetadata] = [
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
    
    public var filteredSurahs: [SurahMetadata] {
        if searchText.isEmpty {
            return surahs
        } else {
            return surahs.filter {
                $0.nameEnglish.localizedCaseInsensitiveContains(searchText) ||
                $0.nameArabic.contains(searchText) ||
                "\($0.number)".contains(searchText)
            }
        }
    }
    
    public func toggleFeaturedAudio() {
        isFeaturedPlaying.toggle()
    }
}
