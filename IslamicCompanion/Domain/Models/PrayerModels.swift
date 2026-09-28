import Foundation

public enum PrayerKind: String, Codable, CaseIterable, Sendable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
    
    public var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }
    
    public var iconName: String {
        switch self {
        case .fajr: return "moon.stars.fill"
        case .sunrise: return "sun.horizon.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }
    
    public var isObligatoryPrayer: Bool {
        return self != .sunrise
    }
}

public enum CalculationMethod: String, Codable, CaseIterable, Sendable {
    case ummAlQura = "Umm Al-Qura (Makkah)"
    case egyptianSurvey = "Egyptian General Authority of Survey"
    case muslimWorldLeague = "Muslim World League"
    case isna = "ISNA (North America)"
    
    public var fajrAngle: Double {
        switch self {
        case .ummAlQura: return 18.5
        case .egyptianSurvey: return 19.5
        case .muslimWorldLeague: return 18.0
        case .isna: return 15.0
        }
    }
    
    public var ishaAngle: Double {
        switch self {
        case .ummAlQura: return 0.0 // Umm Al-Qura uses +90 mins after Maghrib
        case .egyptianSurvey: return 17.5
        case .muslimWorldLeague: return 17.0
        case .isna: return 15.0
        }
    }
}

public enum Madhab: String, Codable, CaseIterable, Sendable {
    case shafii = "Standard (Shafi'i, Maliki, Hanbali)"
    case hanafi = "Hanafi"
    
    public var shadowFactor: Double {
        switch self {
        case .shafii: return 1.0
        case .hanafi: return 2.0
        }
    }
}

public struct PrayerTimeItem: Identifiable, Codable, Sendable {
    public var id: String { kind.rawValue }
    public let kind: PrayerKind
    public let date: Date
    public let formattedTime: String
    public var isPassed: Bool
    public var isCurrentOrNext: Bool
    
    public init(kind: PrayerKind, date: Date, formattedTime: String, isPassed: Bool = false, isCurrentOrNext: Bool = false) {
        self.kind = kind
        self.date = date
        self.formattedTime = formattedTime
        self.isPassed = isPassed
        self.isCurrentOrNext = isCurrentOrNext
    }
}

public struct PrayerSchedule: Codable, Sendable {
    public let date: Date
    public let locationName: String
    public let calculationMethod: CalculationMethod
    public let times: [PrayerTimeItem]
    public let nextPrayer: PrayerTimeItem
    public let nextPrayerCountdownSeconds: Int
    public let solarAltitudeAngle: Double
    
    public init(
        date: Date,
        locationName: String,
        calculationMethod: CalculationMethod,
        times: [PrayerTimeItem],
        nextPrayer: PrayerTimeItem,
        nextPrayerCountdownSeconds: Int,
        solarAltitudeAngle: Double
    ) {
        self.date = date
        self.locationName = locationName
        self.calculationMethod = calculationMethod
        self.times = times
        self.nextPrayer = nextPrayer
        self.nextPrayerCountdownSeconds = nextPrayerCountdownSeconds
        self.solarAltitudeAngle = solarAltitudeAngle
    }
}

public struct QiyamSchedule: Codable, Sendable {
    public let sunset: Date
    public let fajr: Date
    public let midnight: Date
    public let lastThirdStart: Date
    public let formattedLastThird: String
    
    public init(sunset: Date, fajr: Date, midnight: Date, lastThirdStart: Date, formattedLastThird: String) {
        self.sunset = sunset
        self.fajr = fajr
        self.midnight = midnight
        self.lastThirdStart = lastThirdStart
        self.formattedLastThird = formattedLastThird
    }
}
