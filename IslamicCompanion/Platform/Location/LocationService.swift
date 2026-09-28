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
    
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
                self.startHeadingUpdates()
                self.isLocationAvailable = true
            case .denied, .restricted:
                self.isLocationAvailable = false
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
            
            self.geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                guard let placemark = placemarks?.first else { return }
                let city = placemark.locality ?? placemark.administrativeArea ?? "Current Location"
                let country = placemark.country ?? ""
                Task { @MainActor [weak self] in
                    self?.locationName = country.isEmpty ? city : "\(city), \(country)"
                }
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.isLocationAvailable = false
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        Task { @MainActor [weak self] in
            self?.headingDegrees = heading
        }
    }
}
