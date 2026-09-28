import XCTest
@testable import IslamicCompanion

final class PrayerEngineTests: XCTestCase {
    var engine = PrayerEngine()

    override func setUp() {
        super.setUp()
        engine = PrayerEngine()
    }

    func testQiblaBearingFromRiyadh() {
        // Riyadh coordinates: ~24.7136° N, 46.6753° E
        // Qibla direction from Riyadh is towards South-West (~243°)
        let bearing = engine.calculateQiblaBearing(latitude: 24.7136, longitude: 46.6753)
        XCTAssertEqual(bearing, 243.0, accuracy: 2.5, "Qibla bearing from Riyadh should be around 243 degrees")
    }

    func testQiblaBearingFromCairo() {
        // Cairo coordinates: ~30.0444° N, 31.2357° E
        // Qibla direction from Cairo is towards South-East (~136°)
        let bearing = engine.calculateQiblaBearing(latitude: 30.0444, longitude: 31.2357)
        XCTAssertEqual(bearing, 136.0, accuracy: 2.5, "Qibla bearing from Cairo should be around 136 degrees")
    }

    func testPrayerScheduleGeneratesAllSixTimes() {
        let testDate = Date()
        let schedule = engine.calculateSchedule(
            date: testDate,
            latitude: 24.7136,
            longitude: 46.6753,
            method: .ummAlQura
        )
        
        XCTAssertEqual(schedule.times.count, 6, "Schedule must contain 6 entries: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha")
        XCTAssertEqual(schedule.times[0].kind, .fajr)
        XCTAssertEqual(schedule.times[1].kind, .sunrise)
        XCTAssertEqual(schedule.times[2].kind, .dhuhr)
        XCTAssertEqual(schedule.times[3].kind, .asr)
        XCTAssertEqual(schedule.times[4].kind, .maghrib)
        XCTAssertEqual(schedule.times[5].kind, .isha)
    }

    func testQiyamLastThirdCalculation() {
        // Sunset at 18:00, Fajr at 04:00 (10 hours total night duration)
        // Last third = 10 / 3 = 3h 20m before Fajr = 00:40 AM
        let calendar = Calendar.current
        let today = Date()
        guard let sunset = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today),
              let fajrNext = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: today.addingTimeInterval(86400)) else {
            XCTFail("Failed to construct dates")
            return
        }
        
        let qiyam = engine.calculateQiyam(sunset: sunset, fajrNextDay: fajrNext)
        let lastThirdDiff = fajrNext.timeIntervalSince(qiyam.lastThirdStart)
        let expectedDuration = (10.0 * 3600.0) / 3.0
        XCTAssertEqual(lastThirdDiff, expectedDuration, accuracy: 60.0, "Last third must start at 1/3 before Fajr")
    }
}
