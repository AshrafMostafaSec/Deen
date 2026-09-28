import SwiftUI
import Observation

@MainActor
@Observable
public final class RadioViewModel {
    public var stations: [RadioStation] = []
    public var selectedCategory: RadioCategory? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public init() {
        loadCatalog()
    }
    
    public func loadCatalog() {
        guard let url = Bundle.main.url(forResource: "radio_catalog", withExtension: "json") else {
            // Fallback hardcoded verified stations if bundle resource not yet linked
            self.stations = Self.fallbackStations
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let catalog = try JSONDecoder().decode(RadioCatalog.self, from: data)
            self.stations = catalog.stations
        } catch {
            self.stations = Self.fallbackStations
        }
    }
    
    public var featuredStation: RadioStation? {
        stations.first(where: { $0.isFeatured && $0.category == .quran }) ?? stations.first
    }
    
    public var generalStations: [RadioStation] {
        stations.filter { $0.id != featuredStation?.id }
    }
    
    public static let fallbackStations: [RadioStation] = {
        func safeURL(_ str: String) -> URL {
            URL(string: str) ?? URL(fileURLWithPath: "/")
        }
        
        return [
            RadioStation(
                id: "quran-radio-cairo",
                name: "إذاعة القرآن الكريم من القاهرة",
                shortName: "Quran Cairo 98.2 FM",
                frequencyMHz: 98.2,
                category: .quran,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://backup.qurango.net/radio/cairo"), format: .mp3, priority: 1),
                    RadioStreamCandidate(url: safeURL("https://stream.zeno.fm/f3wvbbqmdg8uv"), format: .mp3, priority: 2)
                ],
                isFeatured: true
            ),
            RadioStation(
                id: "el-radio-9090",
                name: "الراديو 9090 FM",
                shortName: "9090 FM",
                frequencyMHz: 90.9,
                category: .general,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://9090streaming.mobtada.com/9090FMEGYPT"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "nogoum-fm",
                name: "نجوم إف إم (Nogoum FM)",
                shortName: "100.6 FM",
                frequencyMHz: 100.6,
                category: .commercial,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://stream.zeno.fm/qb1zvsykm98uv"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "radio-hits",
                name: "راديو هيتس (Radio Hits)",
                shortName: "88.2 FM",
                frequencyMHz: 88.2,
                category: .commercial,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://radiohits882.radioca.st/;"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "sha3by-fm",
                name: "شعبي إف إم (Sha3by FM)",
                shortName: "95.0 FM",
                frequencyMHz: 95.0,
                category: .commercial,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://radio95.radioca.st/;"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "reciter-hussary",
                name: "إذاعة الشيخ محمود خليل الحصري (24/7)",
                shortName: "Al-Hussary 24/7",
                category: .quran,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://backup.qurango.net/radio/mahmoud_khalil_alhussary"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "reciter-minshawi",
                name: "إذاعة الشيخ محمد صديق المنشاوي (24/7)",
                shortName: "Al-Minshawi 24/7",
                category: .quran,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://backup.qurango.net/radio/mohammed_siddiq_alminshawi"), format: .mp3, priority: 1)
                ]
            ),
            RadioStation(
                id: "reciter-abdulbasit",
                name: "إذاعة الشيخ عبد الباسط عبد الصمد (24/7)",
                shortName: "Abdulbasit 24/7",
                category: .quran,
                streamCandidates: [
                    RadioStreamCandidate(url: safeURL("https://backup.qurango.net/radio/abdulbasit_abdulsamad_mojawwad"), format: .mp3, priority: 1)
                ]
            )
        ]
    }()
}
