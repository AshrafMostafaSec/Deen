import Foundation
import CoreLocation
import Observation

@MainActor
@Observable
public final class LocationService: NSObject, CLLocationManagerDelegate {
    public private(set) var latitude: Double = 24.7136 // Default fallback: Riyadh
    public private(set) var longitude: Double = 46.6753
    public private(set) var locationName: String = "Riyadh, Saudi Arabia"
    public private(set) var headingDegrees: Double = 0.0
    public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    public private(set) var isLocationAvailable: Bool = false
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.headingFilter = 1.0 // 1 degree updates for smooth compass
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startHeadingUpdates() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    public func stopHeadingUpdates() {
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            startHeadingUpdates()
            isLocationAvailable = true
        case .denied, .restricted:
            isLocationAvailable = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.isLocationAvailable = true
        
        // Reverse geocode to get human readable city
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let placemark = placemarks?.first else { return }
            let city = placemark.locality ?? placemark.administrativeArea ?? "Current Location"
            let country = placemark.country ?? ""
            Task { @MainActor in
                self.locationName = country.isEmpty ? city : "\(city), \(country)"
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fallback gracefully without crashing
        isLocationAvailable = false
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Prefer true heading if valid, otherwise fallback to magnetic heading
        let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.headingDegrees = heading
    }
}
