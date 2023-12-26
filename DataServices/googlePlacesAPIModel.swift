import SwiftUI
import Foundation
import GooglePlaces
import MapKit
import CoreLocation
import CoreLocationUI


extension locationViewModel {
    
    func fetchPlaces(with query: String) {
        
        let apiKey = "apiKey"
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let autocompleteURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedQuery)&components=country:tr&key=\(apiKey)"
            
            guard let url = URL(string: autocompleteURLString) else {
//                print("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                guard let data = data else {
//                    print("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let predictions = json["predictions"] as? [[String: Any]] {
                        
                        var newItems: [searchItem] = []
                        
                        for prediction in predictions {
                            if let placeId = prediction["place_id"] as? String {
                                self.fetchPlaceDetails(placeId: placeId) { (placeDetails) in
                                    newItems.append(placeDetails)
                                    DispatchQueue.main.async {
                                        self.searchItems = newItems
                                    }
                                }
                            }
                        }
                        
                    }
                } catch {
//                    print("JSON decoding error: \(error)")
                }
            }
            
            task.resume()
        }
        
    }
    
    func fetchPlaceDetails(placeId: String, completion: @escaping (searchItem) -> Void) {
        let apiKey = "apiKey"
        let detailsURLString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=name,formatted_address,geometry&key=\(apiKey)"
        
        guard let url = URL(string: detailsURLString) else {
//            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
//                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
//                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let result = json?["result"] as? [String: Any]
                
                if let name = result?["name"] as? String,
                   let address = result?["formatted_address"] as? String,
                   let geometry = result?["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Double],
                   let lat = location["lat"], let lng = location["lng"] {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let placeDetails = searchItem(name: name, address: address, coordinate: coordinate)
                    completion(placeDetails)
                }
                
            } catch {
//                print("JSON decoding error: \(error)")
            }
        }
        
        task.resume()
    }
}
