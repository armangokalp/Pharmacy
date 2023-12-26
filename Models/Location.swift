import Foundation
import MapKit

struct Location: Identifiable, Equatable {
    
    let id = UUID().uuidString
    let name: String
    let districtName: String
    let cityName: String
    let city: String
    var coordinates: CLLocationCoordinate2D
    let distance: Double
    var isNobetci: Bool
    let isOpen: Bool
    let imageNames: String
    let place_id: String
    let rating: Double
    let address: String
    var phone_number: String
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
