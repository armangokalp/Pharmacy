import Foundation
import MapKit

struct searchItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var address: String?
    var coordinate: CLLocationCoordinate2D?
    var distance: Double?
    var isNobetci: Bool?

    enum CodingKeys: CodingKey {
        case id, name
    }

    static func == (lhs: searchItem, rhs: searchItem) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
