import Foundation
import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI
import SwiftSoup

class locationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @Published var locations: [Location] = []
    @Published var nearestLocations: [Location] = []
    @Published var searchItems: [searchItem] = []
    @Published var onDuty: [String: [String]] = [:]
    
    
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }

    @Published var oldCity: String = ""
    @Published var currentCity: String = ""
    
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    {
        willSet {
            updateCity()
            
            onDutyPharmacyHandler()
        }
        
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (self.mapRegion.span.longitudeDelta < 0.1) {
                    self.fetchPharmacies()
                }
                else {
                    self.locations = []
                    self.expandHeader = false
                }
            }
        }
    }
    
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    let mapSpanFocus = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
    
    @Published var shouldCenterOnUser: Bool = false
    
    @Published var userLocation: CLLocation? {
        didSet {
            guard shouldCenterOnUser, let unwrappedLocation = userLocation else { return }
            updateMapRegion(location: unwrappedLocation)
        }
    }
    private var locationManager = CLLocationManager()
    
    @Published var initializeLocation: Bool = true
    
    @Published var isLocationCenter: Bool = false
    
    @Published var showAlert: Bool = false
    @Published var expandHeader: Bool = false
    @Published var selectionHeader1Active: Bool = true
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    @Published var isLoading: Bool = false
    
    
    
    override init()
    {
        
        // Initializing locations array
        mapLocation = Location(name: "default", districtName: "", cityName: "", city: "", coordinates: CLLocationCoordinate2D(latitude: 41, longitude: 28.97), distance: 0, isNobetci: false, isOpen: false, imageNames: "", place_id: "", rating: 0.0, address: "", phone_number: "")
        super.init()
        
        // User location
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Initialize map location
        if let unwrapped = userLocation {
            mapLocation.coordinates = unwrapped.coordinate
            self.updateMapRegion(location: unwrapped)
            latitude = unwrapped.coordinate.latitude
            longitude = unwrapped.coordinate.longitude
        }
        else {
            self.updateMapRegion(location: mapLocation)
        }
                
        onDutyPharmacyHandler()
        
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        if initializeLocation {
            updateMapRegion(location: location)
            // API
            self.fetchPharmacies()

            initializeLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            self.showAlert = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    func updateMapRegion(location: CLLocation) {
        isLocationCenter = true
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude),
                    span: self.mapSpan)
            }
        }
    }
    
    func updateMapRegion(location: Location) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.mapRegion = MKCoordinateRegion(center: location.coordinates, span: (self.mapRegion.span.longitudeDelta >= 0.008 && self.mapRegion.span.latitudeDelta >= 0.008) ? self.mapSpanFocus : self.mapRegion.span)
            }
        }
    }
    
    
    func updateOrAddLocations(newLocations: [Location]) {

        for newLocation in newLocations {
            if let _ = locations.firstIndex(where: { $0.name == newLocation.name }) {}
            else {
                locations.append(newLocation)
                
                if (locations.count > 30) {
                    locations.removeFirst()
                }
            }
            
            if let _ = nearestLocations.firstIndex(where: { $0.name == newLocation.name }) {}
            else {
                if newLocation.distance < 1.5 {
                    if !(newLocation.distance > 0.7 && !newLocation.isNobetci) {
                        nearestLocations.append(newLocation)

                    }
                }
            }
        }
    }


    func isCoordinate(_ coordinate: CLLocationCoordinate2D, inside region: MKCoordinateRegion) -> Bool {
        let latMin = region.center.latitude - (region.span.latitudeDelta / 1.8)
        let latMax = region.center.latitude + (region.span.latitudeDelta / 1.8)
        let lonMin = region.center.longitude - (region.span.longitudeDelta / 1.8)
        let lonMax = region.center.longitude + (region.span.longitudeDelta / 1.8)
        
        return (latMin...latMax).contains(coordinate.latitude) && (lonMin...lonMax).contains(coordinate.longitude)
    }

    
    
    func adjustAnnotations(_ pharmacyAnnotations: [Location]) -> [Location] {
        let offset: CLLocationDegrees = 0.0002

        var adjustedAnnotations: [Location] = []

        for originalAnnotation in locations {
            var newAnnotation = originalAnnotation
            
            for adjustedAnnotation in adjustedAnnotations {
                if abs(newAnnotation.coordinates.latitude - adjustedAnnotation.coordinates.latitude) < offset &&
                   abs(newAnnotation.coordinates.longitude - adjustedAnnotation.coordinates.longitude) < offset {
                    
                    newAnnotation.coordinates.latitude += offset*1.4
                    newAnnotation.coordinates.longitude += offset*1.4
                }
            }
            
            adjustedAnnotations.append(newAnnotation)
        }
        
        return adjustedAnnotations
        
    }

    
    

    
    func alertDismiss() {
        DispatchQueue.main.async {
            if self.locationManager.authorizationStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    
    func toggleHeader() {
        withAnimation(.easeInOut(duration: 0.5)) {
            expandHeader = !expandHeader
        }
    }
    
    func toggleSelectionHeader() {
        selectionHeader1Active.toggle()
    }
    
    
    func cleanName(_ name: String?) -> String {
        guard let name = name else { return "Eczane" }
        return name
            .lowercased()
            .replacingOccurrences(of: "eczanesi", with: "")
            .replacingOccurrences(of: "eczanesi̇", with: "")
            .replacingOccurrences(of: "pharmacy", with: "")
            .replacingOccurrences(of: "eczane", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
    
    
    
    private func updateCity() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.administrativeArea {
                    DispatchQueue.main.async {
                        self.currentCity = city
                    }
                }
            }
        }
    }
    
    
    private func onDutyPharmacyHandler() {
        if oldCity != currentCity {
            isLoading = true
            print("City has changed to \(currentCity)")
            oldCity = currentCity
            onDuty = [:]
            
            let hiddenWebViewLoader: HiddenWebViewLoader? = HiddenWebViewLoader.shared
            
            if let plateNumber = cityPlateNumbers[currentCity] {
                let plateNumberString = String(plateNumber)
                DispatchQueue.global(qos: .userInitiated).async {
                    hiddenWebViewLoader?.loadContentForCity(city: self.currentCity, plateNumber: plateNumberString) { fetchedHTML in
                        
                        do {
                            let document: Document = try SwiftSoup.parse(fetchedHTML!)
                            let bugunTab: Element? = try document.select("#nav-bugun").first()
                            
                            if let bugunTab = bugunTab {
                                for row in try bugunTab.select("tr") {
                                    let nameElement = try row.select(".col-lg-3 .isim").first()
                                    let districtElement = try row.select(".px-2.py-1.rounded.bg-info.text-white.font-weight-bold").first()
                                    
                                    var pharmacyName: String? = nil
                                    var districtName: String? = nil
                                    
                                    /*let phoneElement = try row.select(".col-lg-3:eq(2)").last()
                                    var phoneNumber: String? = nil
                                    if let phone = try phoneElement?.text() { phoneNumber = phone }
                                    print("fon number: \(phoneNumber ?? "fon yok")") */
                                    
                                    if let name = try nameElement?.text() {
                                        let nameEdit = self.cleanName(name)
                                        pharmacyName = nameEdit.replacingOccurrences(of: " ", with: "")
                                    }
                                    
                                    if let district = try districtElement?.text() {
                                        districtName = district
                                    }
                                    
                                    
                                    if let pharmacyName = pharmacyName, let districtName = districtName {
                                        DispatchQueue.main.async {
                                            if self.onDuty[districtName] == nil {
                                                self.onDuty[districtName] = []
                                            }
                                            
                                            if var pharmacies = self.onDuty[districtName] {
                                                pharmacies.append(pharmacyName)
                                                self.onDuty[districtName] = pharmacies
                                            }
                                            
                                            self.isLoading = false 
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.locations = []
                                        self.nearestLocations = []
                                        self.fetchPharmacies()
                                    }

                                }
                            }
                            
                        } catch {}
                        
                    }
                }
            }

        }
    }
    
    

    
}


