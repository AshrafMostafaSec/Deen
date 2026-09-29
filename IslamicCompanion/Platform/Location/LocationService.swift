import Foundation
import CoreLocation
import Observation

@MainActor
@Observable
public final class LocationService: NSObject, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    // Default fallback: Riyadh, Saudi Arabia
    public static let fallbackLatitude: Double = 24.7136
    public static let fallbackLongitude: Double = 46.6753
    public static let fallbackLocationName: String = "Riyadh, Saudi Arabia"
    
    public private(set) var latitude: Double = fallbackLatitude
    public private(set) var longitude: Double = fallbackLongitude
    public private(set) var locationName: String = fallbackLocationName
    public private(set) var headingDegrees: Double = 0.0
    public private(set) var authorizationStatus: CLAuthorizationStatus
    public private(set) var isLocationAvailable: Bool = false
    public private(set) var isHeadingAvailable: Bool = false
    
    public var isPermissionDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    private let locationManager = CLLocationManager()
    private var lastGeocodedLocation: CLLocation?
    private var geocodeTask: Task<Void, Never>?
    private var activeHeadingConsumers: Int = 0
    
    public override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // 1 km filter prevents continuous polling & battery drain
        locationManager.headingFilter = 1.0 // 1 degree update filter
        self.isHeadingAvailable = CLLocationManager.headingAvailable()
        
        // Immediate resume if already authorized on cold launch
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            self.isLocationAvailable = true
            locationManager.startUpdatingLocation()
        }
    }
    
    public func requestPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Heading Lifecycle Management (On-Demand / Ref-Counted)
    
    public func startHeadingUpdates() {
        guard isHeadingAvailable else { return }
        activeHeadingConsumers += 1
        if activeHeadingConsumers == 1 {
            locationManager.startUpdatingHeading()
        }
    }
    
    public func stopHeadingUpdates() {
        guard isHeadingAvailable else { return }
        activeHeadingConsumers = max(0, activeHeadingConsumers - 1)
        if activeHeadingConsumers == 0 {
            locationManager.stopUpdatingHeading()
        }
    }
    
    public func requestLocationRefresh() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else { return }
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.isLocationAvailable = true
                self.locationManager.startUpdatingLocation()
                if self.activeHeadingConsumers > 0 {
                    self.locationManager.startUpdatingHeading()
                }
            case .denied, .restricted:
                self.isLocationAvailable = false
                self.locationManager.stopUpdatingLocation()
                self.locationManager.stopUpdatingHeading()
                self.geocodeTask?.cancel()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.latitude = lat
            self.longitude = lon
            self.isLocationAvailable = true
            
            self.scheduleReverseGeocode(for: location)
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let clError = error as? CLError {
                // Ignore transient lookup delays while GPS acquires fix
                if clError.code == .locationUnknown {
                    return
                }
                if clError.code == .denied {
                    self.isLocationAvailable = false
                    self.locationManager.stopUpdatingLocation()
                    self.locationManager.stopUpdatingHeading()
                    return
                }
            }
            self.isLocationAvailable = false
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Discard invalid / uncalibrated readings
        guard newHeading.headingAccuracy >= 0 else { return }
        
        // Prefer true heading if valid (>= 0), otherwise fallback to magnetic heading
        let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.headingDegrees = heading
        }
    }
    
    // MARK: - Safe Async Reverse Geocoding
    
    private func scheduleReverseGeocode(for location: CLLocation) {
        if let lastLocation = lastGeocodedLocation,
           location.distance(from: lastLocation) < 2000,
           self.locationName != Self.fallbackLocationName {
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        geocodeTask?.cancel()
        geocodeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let loc = CLLocation(latitude: lat, longitude: lon)
            do {
                let localGeocoder = CLGeocoder()
                let placemarks = try await localGeocoder.reverseGeocodeLocation(loc)
                if Task.isCancelled { return }
                
                if let placemark = placemarks.first {
                    let city = placemark.locality ?? placemark.administrativeArea ?? placemark.subAdministrativeArea ?? "Current Location"
                    let country = placemark.country ?? ""
                    self.locationName = country.isEmpty ? city : "\(city), \(country)"
                    self.lastGeocodedLocation = loc
                }
            } catch {
                if Task.isCancelled { return }
                if self.locationName == Self.fallbackLocationName {
                    let formattedLat = String(format: "%.2f°", lat)
                    let formattedLon = String(format: "%.2f°", lon)
                    self.locationName = "Location (\(formattedLat), \(formattedLon))"
                }
            }
        }
    }
}
