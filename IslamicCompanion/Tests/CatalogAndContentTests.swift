import XCTest
@testable import IslamicCompanion

final class CatalogAndContentTests: XCTestCase {
    
    func testQuranCatalogCompleteness() {
        let surahs = QuranViewModel.fallbackSurahs
        XCTAssertFalse(surahs.isEmpty, "Fallback surahs should not be empty")
        
        let vm = QuranViewModel()
        XCTAssertGreaterThanOrEqual(vm.surahs.count, 18, "Surahs count must be at least the fallback count")
        
        if let first = vm.surahs.first {
            XCTAssertEqual(first.number, 1)
            XCTAssertEqual(first.nameEnglish, "Al-Fatihah")
        }
    }
    
    func testAdhkarFortressCatalog() {
        let vm = AdhkarViewModel()
        XCTAssertEqual(vm.categories.count, 4, "Must have 4 main categories")
        XCTAssertTrue(vm.categories.contains(where: { $0.id == "morning" }))
        XCTAssertTrue(vm.categories.contains(where: { $0.id == "evening" }))
        XCTAssertTrue(vm.categories.contains(where: { $0.id == "post_prayer" }))
        XCTAssertTrue(vm.categories.contains(where: { $0.id == "sleep" }))
    }
    
    func testRadioCatalogStations() {
        let vm = RadioViewModel()
        XCTAssertFalse(vm.stations.isEmpty, "Radio stations catalog must not be empty")
        XCTAssertNotNil(vm.featuredStation, "Must have a featured Quran station")
        XCTAssertTrue(vm.stations.allSatisfy { !$0.streamCandidates.isEmpty }, "All stations must have at least one stream URL")
    }
}
