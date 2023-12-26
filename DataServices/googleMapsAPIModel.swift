import SwiftUI
import GooglePlaces
import Foundation

extension locationViewModel {
    
    func fetchPharmacies() {
        
        let types = ["pharmacy", "drugstore"]

        let group = DispatchGroup()

        for type in types {
            
            group.enter()
            
            let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(mapRegion.center.latitude),\(mapRegion.center.longitude)&radius=\(mapRegion.span.longitudeDelta*90000)&type=\(type)&key=apiKey&language=tr"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                group.leave()
                continue
            }
            
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching data:", error)
                    return
                }
                guard let data = data else {
//                    print("No data returned")
                    return
                }
                
//                print("Response Data:", String(data: data, encoding: .utf8) ?? "Couldn't convert data to string")
                
                
                do {
                    let pharmacyResponse = try JSONDecoder().decode(PharmacyResponse.self, from: data)
                    
                    let newLocations = pharmacyResponse.results.compactMap { pharmacy -> Location? in
                        
                        if let types = pharmacy.types, types.contains("veterinary_care") {
                            return nil
                        }
                        
                        if let name = pharmacy.name, name.contains("MEDİKAL") || name.lowercased().contains("medikal") {
                            return nil
                        }
                        
                        let pharmacyCoordinates = CLLocationCoordinate2D(latitude: pharmacy.geometry?.location?.lat ?? 0.0, longitude: pharmacy.geometry?.location?.lng ?? 0.0)
                        let pharmacyLocation = CLLocation(latitude: pharmacyCoordinates.latitude, longitude: pharmacyCoordinates.longitude)
                        
                        guard let unwrappedUserLocation = self.userLocation else { return nil }
                        
                        func cityName() -> String {
                            if let compoundCode = pharmacy.plus_code?.compound_code {
                                let firstPart = compoundCode.split(separator: ",").first
                                return firstPart?.split(separator: " ").last.map(String.init) ?? ""
                            }
                            return ""
                        }
                        
                        func city() -> String {
                            if let compoundCode = pharmacy.plus_code?.compound_code {
                                let firstPart = compoundCode.split(separator: ",").first
                                let secondPart = firstPart?.split(separator: " ").last ?? ""
                                let parts = secondPart.split(separator: "/")
                                if parts.count > 1 {
                                    return String(parts[1])
                                }
                            }
                            return ""
                        }
                        
                        func district() -> String {
                            return cityName().split(separator: "/").first.map(String.init) ?? ""
                        }
                        
                        let cleanedName = self.cleanName(pharmacy.name)
                        let isNobetci = self.onDuty[district()]?.contains(cleanedName) ?? false
//                        if (isNobetci) { print("onDuty: {\(cleanedName), \(district())}") }

                        return Location(
                            name: pharmacy.name ?? "",
                            districtName: pharmacy.vicinity?.split(separator: ",").first.map(String.init) ?? "",
                            cityName: cityName(),
                            city: city(),
                            coordinates: pharmacyCoordinates,
                            distance: unwrappedUserLocation.distance(from: pharmacyLocation)  / 1000,
                            isNobetci: isNobetci,
                            isOpen: self.isPharmacyOpen(),
                            imageNames: pharmacy.icon ?? "Eczane",
                            place_id: pharmacy.place_id ?? "",
                            rating: pharmacy.rating ?? 0.0,
                            address: pharmacy.vicinity ?? "",
                            phone_number: ""
                        )
                        
                    }

                    // Phone number
                    for pharmacy in pharmacyResponse.results {
                        if let placeID = pharmacy.place_id {
                            self.fetchPhoneNumber(for: placeID) { phoneNumber in
                                DispatchQueue.main.async {
                                    if let index = self.locations.firstIndex(where: { $0.place_id == placeID }) {
                                        self.locations[index].phone_number = phoneNumber ?? ""
                                    }
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.updateOrAddLocations(newLocations: newLocations)
//                        print("Updated Locations:", self.locations)
                    }
                    
                } catch /*let decodeError */{
//                    print("Decoding failed:", decodeError)
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            print("All tasks are done. You can now update the UI.")
        }
        
    }
    
    
    func fetchPhoneNumber(for placeID: String, completion: @escaping (String?) -> ()) {
        let detailsURLString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=formatted_phone_number&key=apiKey"

        guard let detailsURL = URL(string: detailsURLString) else { return }
        let detailsTask = URLSession.shared.dataTask(with: detailsURL) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let phoneNumber = result["formatted_phone_number"] as? String {
                completion(phoneNumber)
            } else {
                completion(nil)
            }
        }
        detailsTask.resume()
    }
    
    
    func isPharmacyOpen() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now) // 1: Sunday, 2: Monday, ...
        
        if weekday == 1 {
            return false
        }
        
        let hour = calendar.component(.hour, from: now)
        
        if hour >= 9 && hour < 19 {
            return true
        }
        
        return false
    }

    
}
