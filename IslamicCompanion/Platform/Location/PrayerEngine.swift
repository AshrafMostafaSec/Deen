import Foundation

/// Pure astronomical calculation engine for prayer times and Qibla bearing
public struct PrayerEngine: Sendable {
    // Kaaba Coordinates (Makkah, Saudi Arabia)
    public static let kaabaLatitude: Double = 21.422487
    public static let kaabaLongitude: Double = 39.826206
    
    public init() {}
    
    /// Calculate complete prayer schedule for a given date, coordinates, and method
    public func calculateSchedule(
        date: Date,
        latitude: Double,
        longitude: Double,
        timeZone: TimeZone = .current,
        method: CalculationMethod = .ummAlQura,
        madhab: Madhab = .shafii,
        locationName: String = "Current Location"
    ) -> PrayerSchedule {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let startOfDay = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.year, .month, .day], from: startOfDay)
        let year = Double(components.year ?? 2026)
        let month = Double(components.month ?? 3)
        let day = Double(components.day ?? 22)
        
        // Timezone offset in hours on this day
        let tzOffsetSeconds = Double(timeZone.secondsFromGMT(for: date))
        let tzOffsetHours = tzOffsetSeconds / 3600.0
        
        // 1. Julian Date at local solar noon (approx 12:00 local time = 12 - tzOffset in UTC)
        let dayFraction = (12.0 - tzOffsetHours) / 24.0
        let jd = julianDate(year: year, month: month, day: day + dayFraction)
        let t = (jd - 2451545.0) / 36525.0
        
        // 2. Solar Position
        let solar = solarCoordinates(t: t)
        let declination = solar.declination
        let eqOfTime = solar.equationOfTime // in minutes
        
        // 3. Solar Noon (Dhuhr in local standard hours)
        let dhuhrLocalHours = 12.0 + tzOffsetHours - (longitude / 15.0) - (eqOfTime / 60.0)
        
        // 4. Sunrise & Sunset (-0.8333° altitude for atmospheric refraction & solar disc)
        let sunriseAngle = -0.8333
        let sunriseHourAngle = hourAngle(altitude: sunriseAngle, latitude: latitude, declination: declination)
        let sunriseLocalHours = dhuhrLocalHours - (sunriseHourAngle / 15.0)
        let sunsetLocalHours = dhuhrLocalHours + (sunriseHourAngle / 15.0)
        
        // 5. Fajr
        let fajrHourAngle = hourAngle(altitude: -method.fajrAngle, latitude: latitude, declination: declination)
        let fajrLocalHours = dhuhrLocalHours - (fajrHourAngle / 15.0)
        
        // 6. Asr
        let shadowFactor = madhab.shadowFactor
        let latDiff = abs(latitude.toRadians() - declination.toRadians())
        let clampedLatDiff = min(latDiff, 89.9.toRadians())
        let asrAltRadians = atan(1.0 / (shadowFactor + tan(clampedLatDiff)))
        let asrAltitude = asrAltRadians.toDegrees()
        let asrHourAngle = hourAngle(altitude: asrAltitude, latitude: latitude, declination: declination)
        let asrLocalHours = dhuhrLocalHours + (asrHourAngle / 15.0)
        
        // 7. Isha
        let ishaLocalHours: Double
        if method == .ummAlQura {
            // Umm Al-Qura uses Maghrib + 90 minutes (1.5 hours)
            ishaLocalHours = sunsetLocalHours + 1.5
        } else {
            let ishaHourAngle = hourAngle(altitude: -method.ishaAngle, latitude: latitude, declination: declination)
            ishaLocalHours = dhuhrLocalHours + (ishaHourAngle / 15.0)
        }
        
        // Convert local hours into Dates relative to startOfDay
        let fajrDate = startOfDay.addingTimeInterval(fajrLocalHours * 3600.0)
        let sunriseDate = startOfDay.addingTimeInterval(sunriseLocalHours * 3600.0)
        let dhuhrDate = startOfDay.addingTimeInterval(dhuhrLocalHours * 3600.0)
        let asrDate = startOfDay.addingTimeInterval(asrLocalHours * 3600.0)
        let maghribDate = startOfDay.addingTimeInterval(sunsetLocalHours * 3600.0)
        let ishaDate = startOfDay.addingTimeInterval(ishaLocalHours * 3600.0)
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        
        let items: [PrayerTimeItem] = [
            PrayerTimeItem(kind: .fajr, date: fajrDate, formattedTime: formatter.string(from: fajrDate)),
            PrayerTimeItem(kind: .sunrise, date: sunriseDate, formattedTime: formatter.string(from: sunriseDate)),
            PrayerTimeItem(kind: .dhuhr, date: dhuhrDate, formattedTime: formatter.string(from: dhuhrDate)),
            PrayerTimeItem(kind: .asr, date: asrDate, formattedTime: formatter.string(from: asrDate)),
            PrayerTimeItem(kind: .maghrib, date: maghribDate, formattedTime: formatter.string(from: maghribDate)),
            PrayerTimeItem(kind: .isha, date: ishaDate, formattedTime: formatter.string(from: ishaDate))
        ]
        
        // Determine Next Prayer and Countdown
        let now = date
        var chosenNext: PrayerTimeItem?
        var countdownSeconds: Int = 0
        var foundNext = false
        
        var updatedItems: [PrayerTimeItem] = []
        for var item in items {
            if item.date <= now {
                item.isPassed = true
            } else if !foundNext {
                item.isCurrentOrNext = true
                chosenNext = item
                countdownSeconds = max(0, Int(item.date.timeIntervalSince(now)))
                foundNext = true
            }
            updatedItems.append(item)
        }
        
        if !foundNext {
            // Next is tomorrow's Fajr
            let tomorrowFajrDate = fajrDate.addingTimeInterval(86400)
            chosenNext = PrayerTimeItem(
                kind: .fajr,
                date: tomorrowFajrDate,
                formattedTime: items.first?.formattedTime ?? "04:30 AM",
                isPassed: false,
                isCurrentOrNext: true
            )
            countdownSeconds = max(0, Int(tomorrowFajrDate.timeIntervalSince(now)))
        }
        
        let currentSolarAltitude = calculateSolarAltitude(now: now, latitude: latitude, longitude: longitude)
        
        return PrayerSchedule(
            date: date,
            locationName: locationName,
            calculationMethod: method,
            times: updatedItems,
            nextPrayer: chosenNext ?? items.first ?? PrayerTimeItem(kind: .fajr, date: date, formattedTime: "--:--"),
            nextPrayerCountdownSeconds: countdownSeconds,
            solarAltitudeAngle: currentSolarAltitude
        )
    }
    
    /// Calculate Qiyam Al-Layl & Last Third schedule
    public func calculateQiyam(
        sunset: Date,
        fajrNextDay: Date,
        timeZone: TimeZone = .current
    ) -> QiyamSchedule {
        let nightDuration = fajrNextDay.timeIntervalSince(sunset)
        let midnight = sunset.addingTimeInterval(nightDuration / 2.0)
        let lastThirdStart = fajrNextDay.addingTimeInterval(-(nightDuration / 3.0))
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        
        return QiyamSchedule(
            sunset: sunset,
            fajr: fajrNextDay,
            midnight: midnight,
            lastThirdStart: lastThirdStart,
            formattedLastThird: formatter.string(from: lastThirdStart)
        )
    }
    
    /// Calculate Spherical Great-Circle Qibla Bearing towards Kaaba (0° - 360°)
    public func calculateQiblaBearing(latitude: Double, longitude: Double) -> Double {
        let lat1 = latitude.toRadians()
        let lon1 = longitude.toRadians()
        let lat2 = Self.kaabaLatitude.toRadians()
        let lon2 = Self.kaabaLongitude.toRadians()
        
        let dLon = lon2 - lon1
        let y = sin(dLon)
        let x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon)
        
        var bearing = atan2(y, x).toDegrees()
        bearing = (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
        return bearing
    }
    
    // MARK: - Private Astronomical Math
    
    private func julianDate(year: Double, month: Double, day: Double) -> Double {
        var y = year
        var m = month
        if m <= 2 {
            y -= 1
            m += 12
        }
        let a = floor(y / 100.0)
        let b = 2.0 - a + floor(a / 4.0)
        return floor(365.25 * (y + 4716.0)) + floor(30.6001 * (m + 1.0)) + day + b - 1524.5
    }
    
    private func solarCoordinates(t: Double) -> (declination: Double, equationOfTime: Double) {
        let l0 = (280.46646 + 36000.76983 * t).truncatingRemainder(dividingBy: 360.0)
        let m = (357.52911 + 35999.05029 * t).truncatingRemainder(dividingBy: 360.0)
        let e = 0.016708634 - 0.000042037 * t
        
        let c = (1.914602 - 0.004817 * t) * sin(m.toRadians())
            + (0.019993 - 0.000101 * t) * sin(2.0 * m.toRadians())
            + 0.000289 * sin(3.0 * m.toRadians())
        
        let trueLon = l0 + c
        let eps = 23.439291 - 0.0130042 * t
        
        let sinDec = sin(eps.toRadians()) * sin(trueLon.toRadians())
        let declination = asin(sinDec).toDegrees()
        
        let y = tan((eps / 2.0).toRadians()) * tan((eps / 2.0).toRadians())
        let eotRad = y * sin(2.0 * l0.toRadians())
            - 2.0 * e * sin(m.toRadians())
            + 4.0 * e * y * sin(m.toRadians()) * cos(2.0 * l0.toRadians())
            - 0.5 * y * y * sin(4.0 * l0.toRadians())
            - 1.25 * e * e * sin(2.0 * m.toRadians())
            
        let equationOfTime = eotRad.toDegrees() * 4.0 // in minutes
        return (declination, equationOfTime)
    }
    
    private func hourAngle(altitude: Double, latitude: Double, declination: Double) -> Double {
        let altRad = altitude.toRadians()
        let latRad = latitude.toRadians()
        let decRad = declination.toRadians()
        
        let cosH = (sin(altRad) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad))
        let clamped = min(max(cosH, -1.0), 1.0)
        return acos(clamped).toDegrees()
    }
    
    private func calculateSolarAltitude(now: Date, latitude: Double, longitude: Double) -> Double {
        let utcTimeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents(in: utcTimeZone, from: now)
        let yearVal = Double(comps.year ?? 2026)
        let monthVal = Double(comps.month ?? 3)
        let dayVal = Double(comps.day ?? 22)
        
        let hourVal = Double(comps.hour ?? 0)
        let minVal = Double(comps.minute ?? 0) / 60.0
        let secVal = Double(comps.second ?? 0) / 3600.0
        let utcHours = hourVal + minVal + secVal
        
        let jd = julianDate(year: yearVal, month: monthVal, day: dayVal + utcHours / 24.0)
        let t = (jd - 2451545.0) / 36525.0
        let solar = solarCoordinates(t: t)
        
        let solarNoonUtc = 12.0 - (longitude / 15.0) - (solar.equationOfTime / 60.0)
        let hourAngleDeg = (utcHours - solarNoonUtc) * 15.0
        
        let term1 = sin(latitude.toRadians()) * sin(solar.declination.toRadians())
        let term2 = cos(latitude.toRadians()) * cos(solar.declination.toRadians()) * cos(hourAngleDeg.toRadians())
        let sinAlt = term1 + term2
            
        return asin(min(max(sinAlt, -1.0), 1.0)).toDegrees()
    }
}

private extension Double {
    func toRadians() -> Double { self * .pi / 180.0 }
    func toDegrees() -> Double { self * 180.0 / .pi }
}
